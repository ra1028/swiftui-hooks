import SwiftUI
import XCTest

@testable import Hooks

final class EnvironmentHookTests: XCTestCase {
    func testMakeValue() {
        let hook = EnvironmentHook(keyPath: \.testValue)
        var environment = EnvironmentValues()

        environment.testValue = 100

        let coordinator = EnvironmentHook<Int>
            .Coordinator(
                state: (),
                environment: environment,
                updateView: {}
            )

        XCTAssertEqual(hook.makeValue(coordinator: coordinator), 100)
    }
}

private struct TestEnvironmentKey: EnvironmentKey {
    static var defaultValue: Int { 0 }
}

private extension EnvironmentValues {
    var testValue: Int {
        get { self[TestEnvironmentKey.self] }
        set { self[TestEnvironmentKey.self] = newValue }
    }
}
