import SwiftUI
import XCTest

@testable import Hooks

final class MemoHookTests: XCTestCase {
    func testMakeState() {
        let hook = MemoHook(
            computation: .always,
            makeValue: { 0 }
        )

        XCTAssertNil(hook.makeState().value)
    }

    func testMakeValue() {
        let hook = MemoHook(
            computation: .always,
            makeValue: { 0 }
        )

        let state = hook.makeState()
        state.value = 100

        let coordinator = MemoHook<Int>
            .Coordinator(
                state: state,
                environment: EnvironmentValues(),
                updateView: {}
            )

        let value = hook.makeValue(coordinator: coordinator)
        XCTAssertEqual(value, 100)
    }

    func testCompute() {
        let hook = MemoHook(
            computation: .always,
            makeValue: { 100 }
        )

        let coordinator = MemoHook<Int>
            .Coordinator(
                state: hook.makeState(),
                environment: EnvironmentValues(),
                updateView: {}
            )

        XCTAssertNil(coordinator.state.value)

        hook.compute(coordinator: coordinator)

        XCTAssertEqual(coordinator.state.value, 100)
    }
}
