import XCTest

@testable import Leader_Key

final class UnixSocketServerTests: XCTestCase {
  func testRunningStateAndStatisticsUseTheSynchronizedSnapshot() {
    let socketPath = "/tmp/leaderkey-tests-\(UUID().uuidString).sock"
    let server = UnixSocketServer(socketPath: socketPath)
    defer { server.stop() }

    XCTAssertFalse(server.isRunning)
    XCTAssertEqual(
      server.statisticsSnapshot(),
      UnixSocketServer.Statistics(totalCommands: 0, socketPath: socketPath, isRunning: false)
    )

    XCTAssertTrue(server.start())
    XCTAssertTrue(server.isRunning)
    XCTAssertEqual(
      server.statisticsSnapshot(),
      UnixSocketServer.Statistics(totalCommands: 0, socketPath: socketPath, isRunning: true)
    )

    server.stop()
    XCTAssertFalse(server.isRunning)
    XCTAssertFalse(FileManager.default.fileExists(atPath: socketPath))
  }
}
