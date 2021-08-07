import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UseRefTests: XCTestCase {
    func testUpdate() {
        let tester = HookTester {
            useRef(0)
        }

        let ref = tester.value

        XCTAssertEqual(ref.current, 0)

        tester.update()
        tester.value.current = 1

        XCTAssertTrue(tester.value === ref)
        XCTAssertEqual(ref.current, 1)
    }

    func testWhenInitialValueIsChanged() {
        let tester = HookTester(0) { initialValue in
            useRef(initialValue)
        }

        XCTAssertEqual(tester.value.current, 0)

        tester.update(with: 1)

        XCTAssertEqual(tester.value.current, 0)
    }
}
