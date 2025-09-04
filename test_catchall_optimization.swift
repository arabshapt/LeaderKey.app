#!/usr/bin/swift
import Foundation

// Test script to verify the catch-all rule optimization
// This simulates what Karabiner2Exporter would generate

func generateTestEDN() -> String {
    let catchAllRule = "   [{:any :key_code :modi :any} [:vk_none] [\"leader_state\" 1]]"
    let modifierPassThrough = """
       [:##left_shift :left_shift :leaderkey_active]
       [:##right_shift :right_shift :leaderkey_active]
       [:##left_command :left_command :leaderkey_active]
       [:##right_command :right_command :leaderkey_active]
       [:##left_option :left_option :leaderkey_active]
       [:##right_option :right_option :leaderkey_active]
       [:##left_control :left_control :leaderkey_active]
       [:##right_control :right_control :leaderkey_active]
    """
    
    return """
    {
     :applications {:vscode ["com.microsoft.VSCode"]
                    :xcode ["com.apple.dt.Xcode"]}
     
     :main [
       {:des "Leader Key - Activation Shortcuts"
        :rules [
          [{:key :k :modi :command} [[\"leaderkey_active\" 1] [\"leader_state\" 1]]]
        ]}
       
       {:des "Leader Key - Modifier Pass-Through"
        :rules [
    \(modifierPassThrough)
        ]}
       
       {:des "Leader Key - Global"
        :rules [
          [:condi :leaderkey_global]
          [:escape [[\"leaderkey_active\" 0] [\"leader_state\" 0]]]
          [:a [[:shell "echo 'action a'"]] [\"leader_state\" 1]]
          [:b [[:shell "echo 'action b'"]] [\"leader_state\" 1]]
          ;; Catch-all rule - single line instead of 50+ rules
    \(catchAllRule)
        ]}
     ]
    }
    """
}

// Print the generated EDN
let edn = generateTestEDN()
print("Generated EDN with optimized catch-all rule:")
print(String(repeating: "=", count: 60))
print(edn)
print(String(repeating: "=", count: 60))
print("\nKey improvements:")
print("1. Single catch-all rule using {:any :key_code :modi :any}")
print("2. All modifier keys (shift, command, option, control) pass through when Leader Key is active")
print("3. Using ## prefix to match modifiers with any combination")
print("4. Significantly reduced EDN file size")