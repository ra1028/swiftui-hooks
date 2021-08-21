import SwiftUI
import XCTest

@testable import Hooks

final class UseEffectTests: XCTestCase {
    func testEffectWithoutPreservationKey() {
        var effectCount = 0

        let tester = HookTester {
            useEffect {
                effectCount += 1
                return nil
            }
        }

        XCTAssertEqual(effectCount, 1)

        tester.update()

        XCTAssertEqual(effectCount, 2)

        tester.update()

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

        tester.update()

        XCTAssertEqual(effectCount, 1)

        tester.update()

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

        tester.update()

        XCTAssertEqual(effectCount, 1)

        flag.toggle()
        tester.update()

        XCTAssertEqual(effectCount, 2)

        tester.update()

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

        tester.dispose()

        XCTAssertEqual(cleanupCount, 1)

        tester.dispose()

        XCTAssertEqual(cleanupCount, 1)

        tester.update()
        tester.dispose()

        XCTAssertEqual(cleanupCount, 2)
    }

    func testLayoutEffectWithoutPreservationKey() {
        var effectCount = 0

        let tester = HookTester {
            useLayoutEffect {
                effectCount += 1
                return nil
            }
        }

        XCTAssertEqual(effectCount, 1)

        tester.update()

        XCTAssertEqual(effectCount, 2)

        tester.update()

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

        tester.update()

        XCTAssertEqual(effectCount, 1)

        tester.update()

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

        tester.update()

        XCTAssertEqual(effectCount, 1)

        flag.toggle()
        tester.update()

        XCTAssertEqual(effectCount, 2)

        tester.update()

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

        tester.dispose()

        XCTAssertEqual(cleanupCount, 1)

        tester.dispose()

        XCTAssertEqual(cleanupCount, 1)

        tester.update()
        tester.dispose()
        XCTAssertEqual(cleanupCount, 2)
    }
}
