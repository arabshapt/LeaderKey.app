import Defaults
import Foundation

struct VoiceDispatchOptions: Sendable {
  let configDirectory: String
  let execute: Bool
  let allowDestructive: Bool
  let plannerMode: VoicePlannerMode
  let cloudPlannerProvider: VoiceCloudPlannerProvider
  let llamaURL: String
  let model: String
  let groqApiKey: String
  let geminiApiKey: String
  let cloudPlannerApiKey: String
  let cloudPlannerBaseURL: String
  let contextJSON: String?

  func withAllowDestructive(_ allow: Bool) -> VoiceDispatchOptions {
    VoiceDispatchOptions(
      configDirectory: configDirectory,
      execute: execute,
      allowDestructive: allow,
      plannerMode: plannerMode,
      cloudPlannerProvider: cloudPlannerProvider,
      llamaURL: llamaURL,
      model: model,
      groqApiKey: groqApiKey,
      geminiApiKey: geminiApiKey,
      cloudPlannerApiKey: cloudPlannerApiKey,
      cloudPlannerBaseURL: cloudPlannerBaseURL,
      contextJSON: contextJSON
    )
  }
}

struct VoiceDispatchResult: Decodable, Sendable {
  let plan: VoiceDispatchPlan
  let validation: VoiceDispatchValidation
  let execution: VoiceDispatchExecution

  var displayMessage: String {
    if execution.blocked {
      return "Voice blocked"
    }
    if execution.needsConfirmation {
      return "Voice needs confirmation"
    }
    if execution.executed {
      return "Voice executed: \(stepSummaryWithPath)"
    }
    if execution.dryRun {
      return "Voice dry run: \(stepSummaryWithPath)"
    }
    if plan.chain.isEmpty {
      if let plannerError = plan.plannerError {
        return "Voice planner error: \(plannerError.prefix(60))"
      }
      return "Voice unresolved"
    }
    return "Voice planned: \(stepSummaryWithPath)"
  }

  var debugSummary: String {
    [
      "mode=\(plan.mode)",
      "confidence=\(String(format: "%.2f", plan.overallConfidence))",
      "valid=\(validation.valid)",
      "blocked=\(execution.blocked)",
      "dryRun=\(execution.dryRun)",
      "executed=\(execution.executed)",
      "steps=\(execution.steps.map(\.actionID).joined(separator: ","))",
      "reason=\"\(execution.reason)\"",
    ].joined(separator: " ")
  }

  private var stepSummary: String {
    let labels = execution.steps.map(\.label).filter { !$0.isEmpty }
    guard !labels.isEmpty else { return "no action" }
    let joined = labels.prefix(2).joined(separator: ", ")
    return labels.count > 2 ? "\(joined), ..." : joined
  }

  private var stepSummaryWithPath: String {
    guard execution.steps.count == 1, let step = execution.steps.first else {
      return stepSummary
    }
    guard !step.label.isEmpty else { return "no action" }
    return step.label
  }

  var isMultiStep: Bool {
    execution.steps.count > 1
  }

  var needsTranscriptionRetry: Bool {
    execution.blocked
      || !validation.valid
      || plan.chain.isEmpty
      || plan.overallConfidence < 0.75
  }

  func isBetterForVoiceThan(_ other: VoiceDispatchResult) -> Bool {
    voiceQualityScore > other.voiceQualityScore + 0.05
  }

  private var voiceQualityScore: Double {
    var score = plan.overallConfidence
    if validation.valid && !execution.blocked {
      score += 1
    }
    if !plan.chain.isEmpty {
      score += 0.5
    }
    if execution.needsConfirmation {
      score -= 0.15
    }
    return score
  }
}

struct VoiceDispatchPlan: Decodable, Sendable {
  let mode: String
  let chain: [VoiceDispatchPlanStep]
  let overallConfidence: Double
  let reason: String
  let plannerError: String?

  private enum CodingKeys: String, CodingKey {
    case mode
    case chain
    case overallConfidence = "overall_confidence"
    case reason
    case plannerError = "planner_error"
  }
}

struct VoiceDispatchPlanStep: Decodable, Sendable {
  let actionID: String
  let confidence: Double

  private enum CodingKeys: String, CodingKey {
    case actionID = "action_id"
    case confidence
  }
}

struct VoiceDispatchValidation: Decodable, Sendable {
  let valid: Bool
  let blocked: Bool
  let needsConfirmation: Bool
  let reason: String

  private enum CodingKeys: String, CodingKey {
    case valid
    case blocked
    case needsConfirmation = "needs_confirmation"
    case reason
  }
}

struct VoiceDispatchExecution: Decodable, Sendable {
  let executed: Bool
  let dryRun: Bool
  let blocked: Bool
  let needsConfirmation: Bool
  let reason: String
  let steps: [VoiceDispatchExecutionStep]

  private enum CodingKeys: String, CodingKey {
    case executed
    case dryRun = "dry_run"
    case blocked
    case needsConfirmation = "needs_confirmation"
    case reason
    case steps
  }
}

struct VoiceDispatchExecutionStep: Decodable, Sendable {
  let actionID: String
  let label: String
  let type: String
  let executed: Bool
  let blocked: Bool
  let requiresConfirmation: Bool
  let reason: String?

  private enum CodingKeys: String, CodingKey {
    case actionID = "action_id"
    case label
    case type
    case executed
    case blocked
    case requiresConfirmation = "requires_confirmation"
    case reason
  }
}

enum VoiceDispatchBridgeError: LocalizedError {
  case dispatcherNotFound
  case nodeNotFound
  case invalidOutput(String)
  case commandFailed(status: Int32, stderr: String, stdout: String)
  case timedOut

  var errorDescription: String? {
    switch self {
    case .dispatcherNotFound:
      return "LeaderKey dispatcher CLI was not found."
    case .nodeNotFound:
      return "Node.js was not found."
    case .invalidOutput(let output):
      return "Dispatcher returned invalid JSON: \(output)"
    case .commandFailed(let status, let stderr, let stdout):
      let detail = [stderr, stdout].joined(separator: "\n").trimmingCharacters(
        in: .whitespacesAndNewlines)
      return "Dispatcher failed with exit code \(status): \(detail)"
    case .timedOut:
      return "Dispatcher timed out."
    }
  }
}

final class VoiceDispatchBridge {
  private enum DispatcherExecutable: Sendable {
    case nodeScript(URL)
    case executable(URL)
  }

  private static let fastTimeout: TimeInterval = 6
  private static let tieredTimeout: TimeInterval = 12

  func dispatch(
    transcript: String,
    bundleId: String?,
    options: VoiceDispatchOptions
  ) async throws -> VoiceDispatchResult {
    let timeout = options.plannerMode.isTiered ? Self.tieredTimeout : Self.fastTimeout
    return try await Task.detached(priority: .userInitiated) {
      try Self.runDispatcher(
        transcript: transcript,
        bundleId: bundleId,
        options: options,
        timeout: timeout
      )
    }.value
  }

  private static func runDispatcher(
    transcript: String,
    bundleId: String?,
    options: VoiceDispatchOptions,
    timeout: TimeInterval
  ) throws -> VoiceDispatchResult {
    let dispatcher = try resolveDispatcher()
    let process = Process()
    let stdout = Pipe()
    let stderr = Pipe()

    let dispatchArguments = makeDispatchArguments(
      transcript: transcript,
      bundleId: bundleId,
      options: options
    )

    switch dispatcher {
    case .nodeScript(let scriptURL):
      let nodeURL = try resolveNode()
      process.executableURL = nodeURL
      process.arguments =
        nodeURL.lastPathComponent == "env"
        ? ["node", scriptURL.path] + dispatchArguments
        : [scriptURL.path] + dispatchArguments
      debugLog(
        "[VoiceDispatchBridge] node=\(nodeURL.path) script=\(scriptURL.path)"
      )
    case .executable(let executableURL):
      process.executableURL = executableURL
      process.arguments = dispatchArguments
      debugLog("[VoiceDispatchBridge] executable=\(executableURL.path)")
    }

    process.environment = processEnvironment()
    process.standardOutput = stdout
    process.standardError = stderr

    // Read pipe data on background threads to avoid pipe-buffer deadlock.
    // If the child writes more than the ~64KB pipe buffer before we read,
    // the write blocks and the process never terminates → timeout.
    var outputData = Data()
    var errorData = Data()
    let readGroup = DispatchGroup()

    readGroup.enter()
    DispatchQueue.global(qos: .userInitiated).async {
      outputData = stdout.fileHandleForReading.readDataToEndOfFile()
      readGroup.leave()
    }

    readGroup.enter()
    DispatchQueue.global(qos: .userInitiated).async {
      errorData = stderr.fileHandleForReading.readDataToEndOfFile()
      readGroup.leave()
    }

    let finished = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in
      finished.signal()
    }

    try process.run()
    if finished.wait(timeout: .now() + timeout) == .timedOut {
      process.terminate()
      throw VoiceDispatchBridgeError.timedOut
    }

    readGroup.wait()

    let output = String(data: outputData, encoding: .utf8) ?? ""
    let error = String(data: errorData, encoding: .utf8) ?? ""

    guard process.terminationStatus == 0 else {
      throw VoiceDispatchBridgeError.commandFailed(
        status: process.terminationStatus,
        stderr: error,
        stdout: output
      )
    }

    guard let data = output.data(using: .utf8),
      let result = try? JSONDecoder().decode(VoiceDispatchResult.self, from: data)
    else {
      throw VoiceDispatchBridgeError.invalidOutput(output)
    }

    return result
  }

  private static func makeDispatchArguments(
    transcript: String,
    bundleId: String?,
    options: VoiceDispatchOptions
  ) -> [String] {
    let plannerFlag: String
    switch options.plannerMode {
    case .tiered:
      plannerFlag = "llama"
    case .tieredOllama:
      plannerFlag = "ollama"
    case .tieredCloud, .cloudOnly:
      plannerFlag = options.cloudPlannerProvider.plannerKind
    case .tieredGroq, .groqOnly:
      plannerFlag = "groq"
    case .tieredGemini, .geminiOnly:
      plannerFlag = "gemini"
    case .fastOnly:
      plannerFlag = "none"
    }

    var arguments = [
      "execute",
      "--config-dir", options.configDirectory,
      "--scope", "frontmost",
      "--planner", plannerFlag,
      "--pretty",
    ]

    if options.plannerMode == .tiered {
      arguments += [
        "--llama-url", options.llamaURL,
        "--model", options.model,
      ]
    } else if options.plannerMode == .tieredOllama {
      arguments += [
        "--ollama-url", options.llamaURL,
        "--model", options.model,
      ]
    } else if options.plannerMode == .tieredCloud || options.plannerMode == .cloudOnly {
      arguments += [
        "--model", options.model,
      ]
      if !options.cloudPlannerBaseURL.isEmpty {
        arguments += ["--planner-base-url", options.cloudPlannerBaseURL]
      }
      switch options.cloudPlannerProvider {
      case .openAI:
        arguments += ["--openai-api-key", options.cloudPlannerApiKey]
      case .openRouter:
        arguments += ["--openrouter-api-key", options.cloudPlannerApiKey]
      case .fireworks:
        arguments += ["--fireworks-api-key", options.cloudPlannerApiKey]
      case .together:
        arguments += ["--together-api-key", options.cloudPlannerApiKey]
      case .deepInfra:
        arguments += ["--deepinfra-api-key", options.cloudPlannerApiKey]
      case .perplexity:
        arguments += ["--perplexity-api-key", options.cloudPlannerApiKey]
      case .compatible:
        arguments += ["--openai-api-key", options.cloudPlannerApiKey]
      }
      if options.plannerMode == .cloudOnly {
        arguments.append("--always-plan")
      }
    } else if options.plannerMode == .tieredGroq || options.plannerMode == .groqOnly {
      arguments += [
        "--groq-api-key", options.groqApiKey,
        "--model", options.model,
      ]
      if options.plannerMode == .groqOnly {
        arguments.append("--always-plan")
      }
    } else if options.plannerMode == .tieredGemini || options.plannerMode == .geminiOnly {
      arguments += [
        "--gemini-api-key", options.geminiApiKey,
        "--model", options.model,
      ]
      if options.plannerMode == .geminiOnly {
        arguments.append("--always-plan")
      }
    }

    if let bundleId, !bundleId.isEmpty {
      arguments += ["--bundle-id", bundleId]
    }
    if let contextJSON = options.contextJSON, !contextJSON.isEmpty {
      arguments += ["--context-json", contextJSON]
    }

    arguments.append(options.execute ? "--execute" : "--dry-run")
    if options.allowDestructive {
      arguments.append("--allow-destructive")
    }
    arguments.append(transcript)
    return arguments
  }

  private static func resolveDispatcher() throws -> DispatcherExecutable {
    let fileManager = FileManager.default
    let environment = ProcessInfo.processInfo.environment

    if let override = environment["LEADERKEY_DISPATCHER_CLI"], !override.isEmpty {
      let url = URL(fileURLWithPath: override)
      guard fileManager.fileExists(atPath: url.path) else {
        throw VoiceDispatchBridgeError.dispatcherNotFound
      }
      return url.pathExtension == "js" ? .nodeScript(url) : .executable(url)
    }

    for root in candidateRepositoryRoots() {
      let scriptURL =
        root
        .appendingPathComponent("packages")
        .appendingPathComponent("leaderkey-dispatcher-cli")
        .appendingPathComponent("dist")
        .appendingPathComponent("index.js")
      if fileManager.fileExists(atPath: scriptURL.path) {
        return .nodeScript(scriptURL)
      }
    }

    if let pathExecutable = findExecutable(named: "leaderkey-dispatcher") {
      return .executable(pathExecutable)
    }

    throw VoiceDispatchBridgeError.dispatcherNotFound
  }

  private static func candidateRepositoryRoots() -> [URL] {
    let environment = ProcessInfo.processInfo.environment
    let fileURL = URL(fileURLWithPath: #filePath)
    let sourceRoot = fileURL.deletingLastPathComponent().deletingLastPathComponent()
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let bundleRoot = Bundle.main.bundleURL
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()

    return [
      environment["LEADERKEY_REPO_ROOT"].map(URL.init(fileURLWithPath:)),
      sourceRoot,
      cwd,
      bundleRoot,
    ]
    .compactMap { $0 }
    .deduplicatedByPath()
  }

  private static func resolveNode() throws -> URL {
    if let node = findExecutable(named: "node") {
      return node
    }
    throw VoiceDispatchBridgeError.nodeNotFound
  }

  private static func findExecutable(named name: String) -> URL? {
    let fileManager = FileManager.default
    for directory in executableSearchPath() {
      let url = URL(fileURLWithPath: directory).appendingPathComponent(name)
      if fileManager.isExecutableFile(atPath: url.path) {
        return url
      }
    }
    return nil
  }

  private static func processEnvironment() -> [String: String] {
    var environment = ProcessInfo.processInfo.environment
    environment["PATH"] = executableSearchPath().joined(separator: ":")
    return environment
  }

  private static func executableSearchPath() -> [String] {
    let currentPath =
      ProcessInfo.processInfo.environment["PATH"]?
      .split(separator: ":")
      .map(String.init) ?? []
    return
      ([
        "/opt/homebrew/bin",
        "/usr/local/bin",
        "/usr/bin",
        "/bin",
        "/usr/sbin",
        "/sbin",
      ] + currentPath).uniqued()
  }
}

extension Array where Element == URL {
  fileprivate func deduplicatedByPath() -> [URL] {
    var seen: Set<String> = []
    return filter { url in
      seen.insert(url.standardizedFileURL.path).inserted
    }
  }
}

extension Array where Element == String {
  fileprivate func uniqued() -> [String] {
    var seen: Set<String> = []
    return filter { value in
      seen.insert(value).inserted
    }
  }
}
