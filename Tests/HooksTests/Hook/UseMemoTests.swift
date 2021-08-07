import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UseMemoTests: XCTestCase {
    func testAlways() {
        var value = 0
        let tester = HookTester {
            useMemo(.always) { () -> Int in
                value
            }
        }

        XCTAssertEqual(tester.value, 0)

        value = 1
        tester.update()

        XCTAssertEqual(tester.value, 1)

        value = 2
        tester.update()

        XCTAssertEqual(tester.value, 2)
    }

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

    func testPreserved() {
        var flag = false
        var value = 0
        let tester = HookTester {
            useMemo(.preserved(by: flag)) { () -> Int in
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
