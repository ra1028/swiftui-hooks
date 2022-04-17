import XCTest

extension XCTestCase {
    func wait(timeout seconds: TimeInterval) {
        let expectation = expectation(description: #function)
        expectation.isInverted = true
        wait(for: [expectation], timeout: seconds)
    }
}
