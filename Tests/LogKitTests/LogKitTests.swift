import XCTest
@testable import LogKit

final class LogKitTests: XCTestCase {

    override func setUp() {
        super.setUp()
        LogKit.clearLogAdapters()
    }

    func testLogPriorityComparison() {
        XCTAssertTrue(LogPriority.verbose < LogPriority.debug)
        XCTAssertTrue(LogPriority.debug < LogPriority.info)
        XCTAssertTrue(LogPriority.info < LogPriority.warn)
        XCTAssertTrue(LogPriority.warn < LogPriority.error)
        XCTAssertTrue(LogPriority.error < LogPriority.assert)
    }

    func testCustomLogAdapter() {
        class MockAdapter: LogAdapter {
            var loggedMessages: [(priority: LogPriority, tag: String?, message: String)] = []

            func log(priority: LogPriority, tag: String?, message: String) {
                loggedMessages.append((priority, tag, message))
            }
        }

        let mock = MockAdapter()
        LogKit.addLogAdapter(mock)

        LogKit.t("TEST_TAG").d("Hello Unit Test")
        XCTAssertEqual(mock.loggedMessages.count, 1)
        XCTAssertEqual(mock.loggedMessages.first?.tag, "TEST_TAG")
        XCTAssertEqual(mock.loggedMessages.first?.priority, .debug)
        XCTAssertEqual(mock.loggedMessages.first?.message, "Hello Unit Test")
    }

    func testJsonFormatting() {
        class MockAdapter: LogAdapter {
            var messages: [String] = []
            func log(priority: LogPriority, tag: String?, message: String) {
                messages.append(message)
            }
        }

        let mock = MockAdapter()
        LogKit.addLogAdapter(mock)

        LogKit.json("{\"name\":\"LogKit\",\"platform\":\"iOS\"}")
        XCTAssertEqual(mock.messages.count, 1)
        let output = mock.messages[0]
        XCTAssertTrue(output.contains("\"name\" : \"LogKit\"") || output.contains("\"name\": \"LogKit\""))
    }

    func testDiskWriteAndRead() {
        let expectation = self.expectation(description: "Disk write and read")
        let tempDir = NSTemporaryDirectory() + "logkit_test_\(UUID().uuidString)"
        LogKit.initOnlyDiskLog(folderPath: tempDir)

        LogKit.d("DISK_TAG", "Disk Message 1")
        LogKit.e("DISK_TAG", "Disk Message 2")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            LogKit.readLog { lines in
                XCTAssertGreaterThanOrEqual(lines.count, 2)
                XCTAssertTrue(lines.joined().contains("Disk Message 1"))
                XCTAssertTrue(lines.joined().contains("Disk Message 2"))
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0)
    }
}
