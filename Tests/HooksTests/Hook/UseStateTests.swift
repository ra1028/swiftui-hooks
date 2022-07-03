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

    func testInitialStateCreatedOnEachUpdate() {
        var updateCalls = 0

        func createState() -> Int {
            updateCalls += 1
            return 0
        }

        let tester = HookTester {
            useState(createState())
        }

        XCTAssertEqual(updateCalls, 1)

        tester.update()

        XCTAssertEqual(updateCalls, 2)

        tester.update()

        XCTAssertEqual(updateCalls, 3)
    }

    func testInitialStateCreateOnceWhenGivenClosure() {
        var closureCalls = 0

        func createState() -> Int {
            closureCalls += 1
            return 0
        }

        let tester = HookTester {
            useState {
                createState()
            }
        }

        XCTAssertEqual(closureCalls, 1)

        tester.update()

        XCTAssertEqual(closureCalls, 1)

        tester.update()

        XCTAssertEqual(closureCalls, 1)
    }

    func testDispose() {
        let tester = HookTester {
            useState(0)
        }

        tester.dispose()
        tester.value.wrappedValue = 1

        XCTAssertEqual(tester.value.wrappedValue, 0)
    }
}
