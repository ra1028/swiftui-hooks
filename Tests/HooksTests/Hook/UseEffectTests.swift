import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UseEffectTests: XCTestCase {
    func testEffectAlways() {
        var effectCount = 0

        let tester = HookTester {
            useEffect(.always) {
                effectCount += 1
                return nil
            }
        }

        XCTAssertEqual(effectCount, 1)

        tester.rerender()

        XCTAssertEqual(effectCount, 2)

        tester.rerender()

        XCTAssertEqual(effectCount, 3)
    }

    func testEffectOnce() {
        var effectCount = 0

        let tester = HookTester {
            useEffect(.once) {
                effectCount += 1
                return nil
            }
        }

        XCTAssertEqual(effectCount, 1)

        tester.rerender()

        XCTAssertEqual(effectCount, 1)

        tester.rerender()

        XCTAssertEqual(effectCount, 1)
    }

    func testEffectPreserved() {
        var flag = false
        var effectCount = 0

        let tester = HookTester {
            useEffect(.preserved(by: flag)) {
                effectCount += 1
                return nil
            }
        }

        XCTAssertEqual(effectCount, 1)

        tester.rerender()

        XCTAssertEqual(effectCount, 1)

        flag.toggle()
        tester.rerender()

        XCTAssertEqual(effectCount, 2)

        tester.rerender()

        XCTAssertEqual(effectCount, 2)
    }

    func testEffectCleanup() {
        var cleanupCount = 0

        let tester = HookTester {
            useEffect(.once) {
                { cleanupCount += 1 }
            }
        }

        XCTAssertEqual(cleanupCount, 0)

        tester.unmount()

        XCTAssertEqual(cleanupCount, 1)

        tester.unmount()

        XCTAssertEqual(cleanupCount, 1)

        tester.rerender()
        tester.unmount()
        XCTAssertEqual(cleanupCount, 2)
    }

    func testLayoutEffectAlways() {
        var effectCount = 0

        let tester = HookTester {
            useLayoutEffect(.always) {
                effectCount += 1
                return nil
            }
        }

        XCTAssertEqual(effectCount, 1)

        tester.rerender()

        XCTAssertEqual(effectCount, 2)

        tester.rerender()

        XCTAssertEqual(effectCount, 3)
    }

    func testLayoutEffectOnce() {
        var effectCount = 0

        let tester = HookTester {
            useLayoutEffect(.once) {
                effectCount += 1
                return nil
            }
        }

        XCTAssertEqual(effectCount, 1)

        tester.rerender()

        XCTAssertEqual(effectCount, 1)

        tester.rerender()

        XCTAssertEqual(effectCount, 1)
    }

    func testLayoutEffectPreserved() {
        var flag = false
        var effectCount = 0

        let tester = HookTester {
            useLayoutEffect(.preserved(by: flag)) {
                effectCount += 1
                return nil
            }
        }

        XCTAssertEqual(effectCount, 1)

        tester.rerender()

        XCTAssertEqual(effectCount, 1)

        flag.toggle()
        tester.rerender()

        XCTAssertEqual(effectCount, 2)

        tester.rerender()

        XCTAssertEqual(effectCount, 2)
    }

    func testLayoutEffectCleanup() {
        var cleanupCount = 0

        let tester = HookTester {
            useLayoutEffect(.once) {
                { cleanupCount += 1 }
            }
        }

        XCTAssertEqual(cleanupCount, 0)

        tester.unmount()

        XCTAssertEqual(cleanupCount, 1)

        tester.unmount()

        XCTAssertEqual(cleanupCount, 1)

        tester.rerender()
        tester.unmount()
        XCTAssertEqual(cleanupCount, 2)
    }
}
