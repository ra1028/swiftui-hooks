import Hooks
import HooksTesting
import SwiftUI
import XCTest

final class HookTesterTests: XCTestCase {
    func testValue() {
        let tester = HookTester {
            useState(0)
        }

        XCTAssertEqual(tester.value.wrappedValue, 0)

        tester.value.wrappedValue = 1

        XCTAssertEqual(tester.value.wrappedValue, 1)
    }

    func testValueHistory() {
        let tester = HookTester {
            useState(0)
        }

        tester.value.wrappedValue = 1
        tester.value.wrappedValue = 2
        tester.value.wrappedValue = 3

        XCTAssertEqual(
            tester.valueHistory.map(\.wrappedValue),
            [0, 1, 2, 3]
        )
    }

    func testRerender() {
        let tester = HookTester(0) { value in
            useMemo(.preserved(by: value)) {
                value
            }
        }

        XCTAssertEqual(tester.value, 0)

        tester.rerender(1)

        XCTAssertEqual(tester.value, 1)

        tester.rerender(2)

        XCTAssertEqual(tester.value, 2)

        XCTAssertEqual(tester.valueHistory, [0, 1, 2])
    }

    func testRerenderWithoutParameter() {
        var value = 0
        let tester = HookTester {
            useMemo(.always) {
                value
            }
        }

        XCTAssertEqual(tester.value, 0)

        value = 1
        tester.rerender()

        XCTAssertEqual(tester.value, 1)

        value = 2
        tester.rerender()

        XCTAssertEqual(tester.value, 2)

        XCTAssertEqual(tester.valueHistory, [0, 1, 2])
    }

    func testUnmount() {
        var isCleanedup = false
        let tester = HookTester {
            useEffect(.once) {
                { isCleanedup = true }
            }
        }

        XCTAssertFalse(isCleanedup)

        tester.unmount()

        XCTAssertTrue(isCleanedup)
    }

    func testEnvironment() {
        let tester = HookTester {
            useEnvironment(\.testValue)
        } scope: {
            $0.environment(\.testValue, 0)
        }

        XCTAssertEqual(tester.value, 0)
    }

    func testContext() {
        enum Value: Int {
            case a, b, c
        }

        typealias ValueContext = Context<Value>

        let tester = HookTester {
            useContext(ValueContext.self)
        } scope: {
            $0.context(ValueContext.self, .a)
        }

        XCTAssertEqual(tester.value, .a)
    }
}

private extension EnvironmentValues {
    enum TestValueKey: EnvironmentKey {
        static var defaultValue: Int? { nil }
    }

    var testValue: Int? {
        get { self[TestValueKey.self] }
        set { self[TestValueKey.self] = newValue }
    }
}
