#!/usr/bin/env swift

import Foundation
import Darwin

// MARK: - Leader Key CLI Tool

enum Command {
    case activate(bundleId: String?)
    case key(keyCode: String)
    case deactivate
    case settings
    case state
    case sequence(keys: String)
    case stateid(id: String, sticky: Bool)
    case help
}

func parseArguments() -> Command {
    let args = CommandLine.arguments
    
    guard args.count > 1 else {
        return .help
    }
    
    switch args[1].lowercased() {
    case "activate":
        let bundleId = args.count > 2 ? args[2] : nil
        return .activate(bundleId: bundleId)
        
    case "key":
        guard args.count > 2 else {
            print("Error: 'key' command requires a keycode parameter")
            exit(1)
        }
        return .key(keyCode: args[2])
        
    case "deactivate":
        return .deactivate
        
    case "settings":
        return .settings
        
    case "state":
        return .state
        
    case "sequence":
        guard args.count > 2 else {
            print("Error: 'sequence' command requires keys parameter")
            exit(1)
        }
        let keys = Array(args[2...]).joined(separator: " ")
        return .sequence(keys: keys)
        
    case "stateid":
        guard args.count > 2 else {
            print("Error: 'stateid' command requires a state ID parameter")
            exit(1)
        }
        // Check for optional sticky flag
        let sticky = args.count > 3 && args[3].lowercased() == "sticky"
        return .stateid(id: args[2], sticky: sticky)
        
    case "help", "--help", "-h":
        return .help
        
    default:
        print("Unknown command: \(args[1])")
        return .help
    }
}

// MARK: - Unix Socket Communication

func sendViaSocket(_ command: String) -> Bool {
    let socketPath = "/tmp/leaderkey.sock"
    
    let socket = Darwin.socket(AF_UNIX, SOCK_STREAM, 0)
    guard socket >= 0 else {
        print("Error: Failed to create socket")
        return false
    }
    defer { close(socket) }
    
    var addr = sockaddr_un()
    addr.sun_family = sa_family_t(AF_UNIX)
    
    socketPath.withCString { pathCString in
        withUnsafeMutablePointer(to: &addr.sun_path.0) { pathPtr in
            strcpy(pathPtr, pathCString)
        }
    }
    
    let connectResult = withUnsafePointer(to: &addr) { addrPtr in
        addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
            connect(socket, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
        }
    }
    
    guard connectResult >= 0 else {
        print("Error: Failed to connect to socket. Is Leader Key running with Karabiner mode enabled?")
        return false
    }
    
    // Send command
    command.withCString { cmdCString in
        _ = send(socket, cmdCString, strlen(cmdCString), 0)
    }
    
    // Read response
    let bufferSize = 4096
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }
    
    let bytesRead = recv(socket, buffer, bufferSize - 1, 0)
    if bytesRead > 0 {
        buffer[bytesRead] = 0
        let response = String(cString: buffer)
        print(response)
        return !response.starts(with: "ERROR")
    }
    
    return false
}

// MARK: - Main

func printHelp() {
    print("""
    Leader Key CLI - Control Leader Key via Unix socket
    
    Usage: leaderkey-cli <command> [options]
    
    Commands:
        activate [bundleId]    Activate Leader Key (optionally for specific app)
        key <keycode>         Send a key event
        deactivate            Deactivate Leader Key
        settings              Open Leader Key settings
        state                 Get current Leader Key state
        sequence <keys>       Send a sequence of keys
        stateid <id> [sticky] Send a state ID for action execution (sticky keeps popup open)
        help                  Show this help message
    
    Examples:
        leaderkey-cli activate
        leaderkey-cli activate com.apple.Terminal
        leaderkey-cli key 40
        leaderkey-cli sequence a b c
        leaderkey-cli deactivate
    
    Note: Requires Leader Key to be running with Karabiner input method enabled.
    """)
}

// Parse command
let command = parseArguments()

// Execute command
let success: Bool

switch command {
case .activate(let bundleId):
    let cmd = bundleId != nil ? "activate \(bundleId!)" : "activate"
    success = sendViaSocket(cmd)
    
case .key(let keyCode):
    success = sendViaSocket("key \(keyCode)")
    
case .deactivate:
    success = sendViaSocket("deactivate")
    
case .settings:
    success = sendViaSocket("settings")
    
case .state:
    success = sendViaSocket("state")
    
case .sequence(let keys):
    success = sendViaSocket("sequence \(keys)")
    
case .stateid(let id, let sticky):
    let cmd = sticky ? "stateid \(id) sticky" : "stateid \(id)"
    success = sendViaSocket(cmd)
    
case .help:
    printHelp()
    success = true
}

exit(success ? 0 : 1)