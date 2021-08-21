import SwiftUI
import XCTest

@testable import Hooks

final class UseHookTests: XCTestCase {
    struct TestHook: Hook {
        final class State {
            var flag = false
            var isUpdated = false
        }

        let updateStrategy: HookUpdateStrategy? = nil

        func makeState() -> State {
            State()
        }

        func value(
            coordinator: Coordinator
        ) -> (flag: Bool, isUpdated: Bool, toggleFlag: () -> Void) {
            (
                flag: coordinator.state.flag,
                isUpdated: coordinator.state.isUpdated,
                toggleFlag: {
                    coordinator.state.flag.toggle()
                    coordinator.updateView()
                }
            )
        }

        func updateState(coordinator: Coordinator) {
            coordinator.state.isUpdated = true
        }
    }

    func testUseHook() {
        let tester = HookTester {
            useHook(TestHook())
        }

        XCTAssertFalse(tester.value.flag)
        XCTAssertTrue(tester.value.isUpdated)

        tester.value.toggleFlag()

        XCTAssertTrue(tester.value.flag)
    }
}
