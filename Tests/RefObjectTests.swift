import Hooks
import XCTest

final class RefObjectTests: XCTestCase {
    func testCurrent() {
        let object = RefObject(0)

        XCTAssertEqual(object.current, 0)

        object.current = 1

        XCTAssertEqual(object.current, 1)
    }
}
