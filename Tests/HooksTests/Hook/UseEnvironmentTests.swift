import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UseEnvironmentTests: XCTestCase {
    func testValue() {
        let tester = HookTester {
            useEnvironment(\.testValue)
        } scope: {
            $0.environment(\.testValue, 100)
        }

        XCTAssertEqual(tester.value, 100)
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
