import SwiftUI
import XCTest

@testable import Hooks

final class ReducerHookTests: XCTestCase {
    func testReducer(state: Int, action: Int) -> Int {
        state + action
    }

    func testMakeState() {
        let hook = ReducerHook(reducer: testReducer, initialState: 100)

        XCTAssertEqual(hook.makeState().state, 100)
    }

    func testMakeValue() {
        var didViewUpdate = false
        let hook = ReducerHook(reducer: testReducer, initialState: 100)
        let coordinator = ReducerHook<Int, Int>
            .Coordinator(
                state: hook.makeState(),
                environment: EnvironmentValues(),
                updateView: { didViewUpdate = true }
            )
        let (state1, dispatch) = hook.makeValue(coordinator: coordinator)

        XCTAssertEqual(state1, 100)
        XCTAssertFalse(didViewUpdate)

        dispatch(100)

        let (state2, _) = hook.makeValue(coordinator: coordinator)

        XCTAssertEqual(state2, 100)
        XCTAssertTrue(didViewUpdate)

        hook.compute(coordinator: coordinator)

        let (state3, _) = hook.makeValue(coordinator: coordinator)

        XCTAssertEqual(state3, 200)
        XCTAssertTrue(didViewUpdate)
    }

    func testCompute() {
        let hook = ReducerHook(reducer: testReducer, initialState: 100)
        let coordinator = ReducerHook<Int, Int>
            .Coordinator(
                state: hook.makeState(),
                environment: EnvironmentValues(),
                updateView: {}
            )

        coordinator.state.nextAction = 100

        hook.compute(coordinator: coordinator)

        XCTAssertEqual(coordinator.state.state, 200)
        XCTAssertNil(coordinator.state.nextAction)
    }
}
