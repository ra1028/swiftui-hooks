import SwiftUI
import XCTest

@testable import Hooks

final class HookDispatcherTests: XCTestCase {
    final class Counter {
        var count = 0
    }

    final class TestHook: Hook {
        let computation: HookComputation
        let shouldDeferredCompute: Bool
        let disposeCounter: Counter
        var disposedAt: Int?

        init(
            computation: HookComputation = .always,
            shouldDeferredCompute: Bool = false,
            disposeCounter: Counter? = nil
        ) {
            self.computation = computation
            self.shouldDeferredCompute = shouldDeferredCompute
            self.disposeCounter = disposeCounter ?? Counter()
        }

        func dispose(state: RefObject<Int>) {
            disposeCounter.count += 1
            disposedAt = disposeCounter.count
        }

        func compute(coordinator: Coordinator) {
            coordinator.state.current += 1
        }

        func makeState() -> RefObject<Int> {
            RefObject(0)
        }

        func makeValue(coordinator: Coordinator) -> Int {
            coordinator.state.current
        }
    }

    final class Test2Hook: Hook {
        let computation = HookComputation.always
        let disposeCounter: Counter
        var disposedAt: Int?

        init(disposeCounter: Counter? = nil) {
            self.disposeCounter = disposeCounter ?? Counter()
        }

        func dispose(state: Void) {
            disposeCounter.count += 1
            disposedAt = disposeCounter.count
        }
    }

    func testScoped() {
        let dispatcher = HookDispatcher()

        XCTAssertNil(HookDispatcher.current)

        dispatcher.scoped(environment: EnvironmentValues()) {
            XCTAssertTrue(HookDispatcher.current === dispatcher)
        }

        XCTAssertNil(HookDispatcher.current)
    }

    func testUse() {
        let dispatcher = HookDispatcher()
        let alwaysHook = TestHook(computation: .always)
        let onceHook = TestHook(computation: .once)
        let deferredHook = TestHook(computation: .always, shouldDeferredCompute: true)

        dispatcher.scoped(environment: EnvironmentValues()) {
            let value1 = alwaysHook.use()
            let value2 = onceHook.use()
            let value3 = deferredHook.use()

            XCTAssertEqual(value1, 1)  // Compute always
            XCTAssertEqual(value2, 1)  // Compute once
            XCTAssertEqual(value3, 0)  // Computation is deferred
        }

        dispatcher.scoped(environment: EnvironmentValues()) {
            let value1 = alwaysHook.use()
            let value2 = onceHook.use()
            let value3 = deferredHook.use()

            XCTAssertEqual(value1, 2)  // Compute always
            XCTAssertEqual(value2, 1)  // Already computed once
            XCTAssertEqual(value3, 1)  // Computation is deferred
        }

        dispatcher.scoped(environment: EnvironmentValues()) {
            let value1 = alwaysHook.use()
            let value2 = onceHook.use()
            let value3 = deferredHook.use()

            XCTAssertEqual(value1, 3)  // Compute always
            XCTAssertEqual(value2, 1)  // Already computed once
            XCTAssertEqual(value3, 2)  // Computation is deferred
        }
    }

    func testMismatchTypedHookFound() {
        let dispatcher = HookDispatcher()
        let disposeCounter = Counter()
        let hook1 = TestHook(disposeCounter: disposeCounter)
        let hook2 = Test2Hook(disposeCounter: disposeCounter)
        let hook3 = TestHook(disposeCounter: disposeCounter)
        let hook4 = TestHook(disposeCounter: disposeCounter)

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            let value1 = hook1.use()  // Int
            hook2.use()  // Void
            let value3 = hook3.use()  // Int
            let value4 = hook4.use()  // Int

            XCTAssertEqual(value1, 1)
            XCTAssertEqual(value3, 1)
            XCTAssertEqual(value4, 1)
        }

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            let value1 = hook1.use()
            // _ = hook2.use()
            let value3 = hook3.use()  // Type mismatched here: Void -> Int
            let value4 = hook4.use()

            XCTAssertEqual(value1, 2)  // Works correctly
            XCTAssertEqual(value3, 1)  // State is initialized
            XCTAssertEqual(value4, 1)  // State is initialized
        }

        // Disposed in reverse order
        XCTAssertNil(hook1.disposedAt)
        XCTAssertEqual(hook2.disposedAt, 3)
        XCTAssertEqual(hook3.disposedAt, 2)
        XCTAssertEqual(hook4.disposedAt, 1)
        XCTAssertEqual(disposeCounter.count, 3)

        dispatcher.scoped(disablesAssertion: false, environment: EnvironmentValues()) {
            let value1 = hook1.use()
            // _ = hook2.use()
            let value3 = hook3.use()
            let value4 = hook4.use()

            XCTAssertEqual(value1, 3)  // Works correctly
            XCTAssertEqual(value3, 2)  // Works correctly
            XCTAssertEqual(value4, 2)  // Works correctly
        }
    }

    func testNumberOfHooksMismatched() {
        let dispatcher = HookDispatcher()
        let disposeCounter = Counter()
        let hook1 = TestHook(disposeCounter: disposeCounter)
        let hook2 = TestHook(disposeCounter: disposeCounter)
        let hook3 = TestHook(disposeCounter: disposeCounter)

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            // There are 2 hooks
            let value1 = hook1.use()
            let value2 = hook2.use()
            let value3 = hook3.use()

            XCTAssertEqual(value1, 1)
            XCTAssertEqual(value2, 1)
            XCTAssertEqual(value3, 1)
        }

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            // There is 1 hook
            let value1 = hook1.use()
            // let value2 = hook2.use()
            // let value3 = hook3.use()

            XCTAssertEqual(value1, 2)  // Works correctly
        }

        XCTAssertNil(hook1.disposedAt)
        XCTAssertEqual(hook2.disposedAt, 2)
        XCTAssertEqual(hook3.disposedAt, 1)
        XCTAssertEqual(disposeCounter.count, 2)

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            let value1 = hook1.use()
            let value2 = hook2.use()
            let value3 = hook3.use()

            XCTAssertEqual(value1, 3)  // Works correctly
            XCTAssertEqual(value2, 1)  // Previous state is initialized
            XCTAssertEqual(value3, 1)  // Previous state is initialized
        }

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            let value1 = hook1.use()
            let value2 = hook2.use()
            let value3 = hook3.use()

            XCTAssertEqual(value1, 4)  // Works correctly
            XCTAssertEqual(value2, 2)  // Works correctly
            XCTAssertEqual(value3, 2)  // Works correctly
        }
    }

    func testReversedDisposeWhenDeinit() {
        var dispatcher: HookDispatcher? = HookDispatcher()
        let disposeCounter = Counter()
        let hook1 = TestHook(disposeCounter: disposeCounter)
        let hook2 = TestHook(disposeCounter: disposeCounter)

        dispatcher?
            .scoped(environment: EnvironmentValues()) {
                _ = hook1.use()
                _ = hook2.use()
            }

        XCTAssertEqual(disposeCounter.count, 0)

        dispatcher = nil

        XCTAssertEqual(disposeCounter.count, 2)
        XCTAssertEqual(hook1.disposedAt, 2)
        XCTAssertEqual(hook2.disposedAt, 1)
    }
}
