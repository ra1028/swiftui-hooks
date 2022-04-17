import XCTest

struct TestError: Error, Equatable {
    let value: Int
}

extension XCTestCase {
    func wait(timeout seconds: TimeInterval) {
        let expectation = expectation(description: #function)
        expectation.isInverted = true
        wait(for: [expectation], timeout: seconds)
    }
}
