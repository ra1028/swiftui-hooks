import SwiftUI
import XCTest

@testable import Hooks

final class UseMemoTests: XCTestCase {
    func testOnce() {
        var value = 0
        let tester = HookTester {
            useMemo(.once) { () -> Int in
                value
            }
        }

        XCTAssertEqual(tester.value, 0)

        value = 1
        tester.update()

        XCTAssertEqual(tester.value, 0)

        value = 2
        tester.update()

        XCTAssertEqual(tester.value, 0)
    }

    func testPrevented() {
        var flag = false
        var value = 0
        let tester = HookTester {
            useMemo(.prevented(by: flag)) { () -> Int in
                value
            }
        }

        XCTAssertEqual(tester.value, 0)

        value = 1
        tester.update()

        XCTAssertEqual(tester.value, 0)

        flag.toggle()
        value = 2
        tester.update()

        XCTAssertEqual(tester.value, 2)
    }
}
