import SwiftUI
import XCTest
import HooksTesting

@testable import Hooks

final class UseHookTests: XCTestCase {
    struct TestHook: Hook {
        final class State {
            var flag = false
            var isComputed = false
        }

        let computation = HookComputation.always

        func makeState() -> State {
            State()
        }

        func makeValue(
            coordinator: Coordinator
        ) -> (flag: Bool, isComputed: Bool, toggleFlag: () -> Void) {
            (
                flag: coordinator.state.flag,
                isComputed: coordinator.state.isComputed,
                toggleFlag: {
                    coordinator.state.flag.toggle()
                    coordinator.updateView()
                }
            )
        }

        func compute(coordinator: Coordinator) {
            coordinator.state.isComputed = true
        }
    }

    func testUseHook() {
        let tester = HookTester {
            useHook(TestHook())
        }

        XCTAssertFalse(tester.value.flag)
        XCTAssertTrue(tester.value.isComputed)

        tester.value.toggleFlag()

        XCTAssertTrue(tester.value.flag)
    }
}
