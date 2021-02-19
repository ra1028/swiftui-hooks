import SwiftUI
import XCTest

@testable import Hooks

final class StateHookTests: XCTestCase {
    func testMakeState() {
        let hook = StateHook(initialState: 100)

        XCTAssertEqual(hook.makeState().state, 100)
    }

    func testMakeValue() {
        var didViewUpdate = false
        let hook = StateHook(initialState: 100)
        let coordinator = StateHook<Int>
            .Coordinator(
                state: hook.makeState(),
                environment: EnvironmentValues(),
                updateView: { didViewUpdate = true }
            )

        let state = hook.makeValue(coordinator: coordinator)

        XCTAssertFalse(didViewUpdate)
        XCTAssertEqual(state.wrappedValue, 100)

        state.wrappedValue = 200

        XCTAssertTrue(didViewUpdate)
        XCTAssertEqual(coordinator.state.state, 200)
    }
}
