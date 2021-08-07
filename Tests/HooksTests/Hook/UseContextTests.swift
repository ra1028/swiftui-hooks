import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UseContextTests: XCTestCase {
    func testValue() {
        let tester = HookTester {
            useContext(TestContext.self)
        } environment: {
            $0[TestContext.self] = 100
        }

        XCTAssertEqual(tester.value, 100)
    }
}

private typealias TestContext = Context<Int>
