import os

/// Shared signpost log for Instruments profiling of Leader Key hot paths.
let signpostLog = OSLog(subsystem: "com.leaderkey.app", category: .pointsOfInterest)
