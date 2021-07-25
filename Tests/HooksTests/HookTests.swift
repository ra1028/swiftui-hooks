import SwiftUI
import XCTest

@testable import Hooks

final class HookTests: XCTestCase {
    final class TestHook: Hook {
        var isComputed = false
        let computation = HookComputation.always

        func compute(coordinator: Coordinator) {
            isComputed = true
        }
    }

    func testUseHook() {
        let dispatcher = HookDispatcher()
        let hook = TestHook()

        XCTAssertFalse(hook.isComputed)

        dispatcher.scoped(environment: EnvironmentValues()) {
            useHook(hook)
        }

        XCTAssertTrue(hook.isComputed)
    }
}
