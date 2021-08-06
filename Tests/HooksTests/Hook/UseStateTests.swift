import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UseStateTests: XCTestCase {
    func testUpdate() {
        let tester = HookTester {
            useState(0)
        }

        XCTAssertEqual(tester.value.wrappedValue, 0)

        tester.value.wrappedValue = 1

        XCTAssertEqual(tester.value.wrappedValue, 1)

        tester.value.wrappedValue = 2

        XCTAssertEqual(tester.value.wrappedValue, 2)

        tester.dispose()
        tester.update()

        XCTAssertEqual(tester.value.wrappedValue, 0)
    }

    func testWhenInitialStateIsChanged() {
        let tester = HookTester(0) { initialState in
            useState(initialState)
        }

        XCTAssertEqual(tester.value.wrappedValue, 0)

        tester.update(with: 1)

        XCTAssertEqual(tester.value.wrappedValue, 0)

        tester.update()

        XCTAssertEqual(tester.value.wrappedValue, 0)
    }
}
