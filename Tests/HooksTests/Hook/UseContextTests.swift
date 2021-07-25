import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UseContextTests: XCTestCase {
    func testValue() {
        let tester = HookTester {
            useContext(TestContext.self)
        } scope: {
            $0.context(TestContext.self, 100)
        }

        XCTAssertEqual(tester.value, 100)
    }
}

private typealias TestContext = Context<Int>
