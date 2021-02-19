import Hooks
import XCTest

final class AsyncStatusTests: XCTestCase {
    func testResult() {
        let statuses: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [Result<Int, URLError>?] = [
            nil,
            nil,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        for (status, expected) in zip(statuses, expected) {
            XCTAssertEqual(status.result, expected)
        }
    }
}
