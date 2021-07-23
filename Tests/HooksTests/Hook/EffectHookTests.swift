import SwiftUI
import XCTest

@testable import Hooks

final class EffectHookTests: XCTestCase {
    func testMakeState() {
        let hook = EffectHook(
            computation: .always,
            shouldDeferredCompute: false,
            effect: { nil }
        )
        let state = hook.makeState()

        XCTAssertNil(state.cleanup)
    }

    func testCompute() {
        var didEffect = false
        var didCleanup = false
        let hook = EffectHook(
            computation: .always,
            shouldDeferredCompute: false,
            effect: {
                didEffect = true
                return { didCleanup = true }
            }
        )
        let coordinator = EffectHook.Coordinator(
            state: EffectHook.State(),
            environment: EnvironmentValues(),
            updateView: {}
        )

        hook.compute(coordinator: coordinator)

        XCTAssertTrue(didEffect)
        XCTAssertFalse(didCleanup)

        coordinator.state.cleanup?()

        XCTAssertTrue(didEffect)
        XCTAssertTrue(didCleanup)
    }

    func testDispose() {
        let hook = EffectHook(
            computation: .always,
            shouldDeferredCompute: false,
            effect: { nil }
        )
        let coordinator = EffectHook.Coordinator(
            state: EffectHook.State(),
            environment: EnvironmentValues(),
            updateView: {}
        )

        coordinator.state.cleanup = {}

        XCTAssertNotNil(coordinator.state.cleanup)

        hook.dispose(state: coordinator.state)

        XCTAssertNil(coordinator.state.cleanup)
    }
}
