import Combine
import SwiftUI
import XCTest

@testable import Hooks

@MainActor
final class UseAsyncPerformTests: XCTestCase {
    func testUpdate() async {
        let tester = HookTester(0) { value in
            useAsyncPerform { () async -> Int in
                try? await Task.sleep(nanoseconds: 50_000_000)
                return value
            }
        }

        XCTAssertEqual(tester.value.phase, .pending)

        await tester.value.perform()

        XCTAssertEqual(tester.value.phase.value, 0)

        tester.update(with: 1)
        await tester.value.perform()
        XCTAssertEqual(tester.value.phase.value, 1)

        tester.update(with: 2)
        await tester.value.perform()
        XCTAssertEqual(tester.value.phase.value, 2)
    }

    func testUpdateWithError() async {
        let tester = HookTester(0) { value in
            useAsyncPerform { () async throws -> Int in
                try await Task.sleep(nanoseconds: 50_000_000)
                throw TestError(value: value)
            }
        }

        XCTAssertTrue(tester.value.phase.isPending)

        await tester.value.perform()

        XCTAssertEqual(tester.value.phase.error as? TestError, TestError(value: 0))

        tester.update(with: 1)
        await tester.value.perform()
        XCTAssertEqual(tester.value.phase.error as? TestError, TestError(value: 1))

        tester.update(with: 2)
        await tester.value.perform()
        XCTAssertEqual(tester.value.phase.error as? TestError, TestError(value: 2))
    }

    func testDispose() async {
        var isPerformed = false
        let tester = HookTester {
            useAsyncPerform { () async -> Int in
                isPerformed = true
                return 0
            }
        }

        XCTAssertTrue(tester.value.phase.isPending)

        tester.dispose()
        wait(timeout: 0.1)

        XCTAssertTrue(tester.value.phase.isPending)
        XCTAssertFalse(isPerformed)

        await tester.value.perform()

        XCTAssertTrue(tester.value.phase.isPending)
        XCTAssertFalse(isPerformed)
    }

    func testDisposeWithError() async {
        var isPerformed = false
        let tester = HookTester {
            useAsyncPerform { () async throws -> Int in
                isPerformed = true
                throw TestError(value: 0)
            }
        }

        XCTAssertTrue(tester.value.phase.isPending)

        tester.dispose()
        wait(timeout: 0.1)

        XCTAssertTrue(tester.value.phase.isPending)
        XCTAssertFalse(isPerformed)

        await tester.value.perform()

        XCTAssertTrue(tester.value.phase.isPending)
        XCTAssertFalse(isPerformed)
    }
}
