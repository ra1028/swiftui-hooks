import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UseReducerTests: XCTestCase {
    func testUpdate() {
        func reducer(state: Int, action: Int) -> Int {
            state + action
        }

        let tester = HookTester {
            useReducer(reducer, initialState: 0)
        }

        XCTAssertEqual(tester.value.state, 0)

        tester.value.dispatch(1)

        XCTAssertEqual(tester.value.state, 1)

        tester.value.dispatch(2)

        XCTAssertEqual(tester.value.state, 3)

        tester.unmount()
        tester.rerender()

        XCTAssertEqual(tester.value.state, 0)
    }

    func testWhenInitialStateIsChanged() {
        func reducer(state: Int, action: Int) -> Int {
            state + action
        }

        let tester = HookTester(0) { initialState in
            useReducer(reducer, initialState: initialState)
        }

        XCTAssertEqual(tester.value.state, 0)

        tester.rerender(1)

        XCTAssertEqual(tester.value.state, 0)

        tester.rerender()

        XCTAssertEqual(tester.value.state, 0)
    }
}
