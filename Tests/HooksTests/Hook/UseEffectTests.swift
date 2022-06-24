import SwiftUI
import XCTest

@testable import Hooks

final class UseEffectTests: XCTestCase {
    enum EffectOperation: Equatable {
        case effect(Int)
        case cleanup(Int)
    }

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

    func testEffectOperationsOrder() {
        var operations: [EffectOperation] = []
        var step = 1

        let tester = HookTester {
            useEffect(.preserved(by: step)) {
                let effectStep = step
                operations.append(.effect(effectStep))
                return { operations.append(.cleanup(effectStep)) }
            }
        }

        XCTAssertEqual(operations, [.effect(1)])

        step += 1
        tester.update()

        XCTAssertEqual(operations, [.effect(1), .cleanup(1), .effect(2)])

        tester.dispose()

        XCTAssertEqual(operations, [.effect(1), .cleanup(1), .effect(2), .cleanup(2)])
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

    func testLayoutEffectOperationsOrder() {
        var operations: [EffectOperation] = []
        var step = 1

        let tester = HookTester {
            useLayoutEffect(.preserved(by: step)) {
                let effectStep = step
                operations.append(.effect(effectStep))
                return { operations.append(.cleanup(effectStep)) }
            }
        }

        XCTAssertEqual(operations, [.effect(1)])

        step += 1
        tester.update()

        XCTAssertEqual(operations, [.effect(1), .cleanup(1), .effect(2)])

        tester.dispose()

        XCTAssertEqual(operations, [.effect(1), .cleanup(1), .effect(2), .cleanup(2)])
    }
}
