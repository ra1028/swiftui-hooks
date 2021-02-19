import SwiftUI
import XCTest

@testable import Hooks

final class ContextHookTests: XCTestCase {
    typealias TestContext = Context<Int>

    func testMakeValue() {
        let hook = ContextHook(context: TestContext.self)

        var environment = EnvironmentValues()
        environment[TestContext.self] = 100

        let coordinator = ContextHook<Int>
            .Coordinator(
                state: (),
                environment: environment,
                updateView: {}
            )

        let value = hook.makeValue(coordinator: coordinator)

        XCTAssertEqual(value, 100)
    }
}
