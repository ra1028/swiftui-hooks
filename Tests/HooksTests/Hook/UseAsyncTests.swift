import Combine
import SwiftUI
import XCTest

@testable import Hooks

@MainActor
final class UseAsyncTests: XCTestCase {
    func testUpdateOnce() {
        let tester = HookTester(0) { value in
            useAsync(.once) {
                value
            }
        }

        XCTAssertEqual(tester.value, .running)

        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: 1)
        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: 2)
        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.value, 0)
    }

    func testUpdateOnceWithError() {
        let tester = HookTester(0) { _ in
            useAsync(.once) { () async throws -> Int in
                throw TestError(value: 0)
            }
        }

        XCTAssertTrue(tester.value.isRunning)

        wait(timeout: 0.1)

        XCTAssertEqual(
            tester.valueHistory.map {
                $0.mapError { $0 as! TestError }
            },
            [.running, .failure(TestError(value: 0))]
        )
    }

    func testUpdatePreserved() {
        let tester = HookTester((0, false)) { value, flag in
            useAsync(.preserved(by: flag)) {
                value
            }
        }

        XCTAssertTrue(tester.value.isRunning)

        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: (1, false))
        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: (2, true))
        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.value, 2)

        tester.update(with: (3, true))
        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.value, 2)
    }

    func testUpdatePreservedWithError() {
        let tester = HookTester((0, false)) { value, flag in
            useAsync(.preserved(by: flag)) { () async throws -> Int in
                throw TestError(value: value)
            }
        }

        XCTAssertTrue(tester.value.isRunning)

        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.error as? TestError, TestError(value: 0))

        tester.update(with: (1, false))
        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.error as? TestError, TestError(value: 0))

        tester.update(with: (2, true))
        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.error as? TestError, TestError(value: 2))

        tester.update(with: (3, true))
        wait(timeout: 0.1)
        XCTAssertEqual(tester.value.error as? TestError, TestError(value: 2))
    }

    func testDispose() {
        let tester = HookTester {
            useAsync(.once) { () async -> Int in
                try? await Task.sleep(nanoseconds: 50_000_000)
                return 0
            }
        }

        XCTAssertTrue(tester.value.isRunning)

        tester.dispose()
        wait(timeout: 0.1)

        XCTAssertTrue(tester.value.isRunning)
    }

    func testDisposeWithError() {
        let tester = HookTester {
            useAsync(.once) { () async throws -> Int in
                try await Task.sleep(nanoseconds: 50_000_000)
                throw TestError(value: 0)
            }
        }

        XCTAssertTrue(tester.value.isRunning)

        tester.dispose()
        wait(timeout: 0.1)

        XCTAssertTrue(tester.value.isRunning)
    }
}
