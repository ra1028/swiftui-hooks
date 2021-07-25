import SwiftUI
import XCTest

@testable import Hooks

final class RefHookTests: XCTestCase {
    func testMakeState() {
        let hook = RefHook(initialValue: 100)

        XCTAssertEqual(hook.makeState().current, 100)
    }

    func testMakeValue() {
        let hook = RefHook(initialValue: 100)
        let coordinator = RefHook<Int>
            .Coordinator(
                state: hook.makeState(),
                environment: EnvironmentValues(),
                updateView: {}
            )
        let value = hook.makeValue(coordinator: coordinator)

        XCTAssertEqual(value.current, 100)
    }
}
