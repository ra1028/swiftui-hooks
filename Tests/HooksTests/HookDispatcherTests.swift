import SwiftUI
import XCTest

@testable import Hooks

final class HookDispatcherTests: XCTestCase {
    final class Counter {
        var count = 0
    }

    final class TestHook: Hook {
        let updateStrategy: HookUpdateStrategy?
        let shouldDeferredCompute: Bool
        let disposeCounter: Counter
        var disposedAt: Int?

        init(
            updateStrategy: HookUpdateStrategy? = nil,
            shouldDeferredCompute: Bool = false,
            disposeCounter: Counter? = nil
        ) {
            self.updateStrategy = updateStrategy
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
        let updateStrategy: HookUpdateStrategy? = nil
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
        let hookWithoutPreservation = TestHook(updateStrategy: nil)
        let onceHook = TestHook(updateStrategy: .once)
        let deferredHook = TestHook(updateStrategy: nil, shouldDeferredCompute: true)

        dispatcher.scoped(environment: EnvironmentValues()) {
            let value1 = useHook(hookWithoutPreservation)
            let value2 = useHook(onceHook)
            let value3 = useHook(deferredHook)

            XCTAssertEqual(value1, 1)  // Compute always
            XCTAssertEqual(value2, 1)  // Compute once
            XCTAssertEqual(value3, 0)  // Computation is deferred
        }

        dispatcher.scoped(environment: EnvironmentValues()) {
            let value1 = useHook(hookWithoutPreservation)
            let value2 = useHook(onceHook)
            let value3 = useHook(deferredHook)

            XCTAssertEqual(value1, 2)  // Compute always
            XCTAssertEqual(value2, 1)  // Already computed once
            XCTAssertEqual(value3, 1)  // Computation is deferred
        }

        dispatcher.scoped(environment: EnvironmentValues()) {
            let value1 = useHook(hookWithoutPreservation)
            let value2 = useHook(onceHook)
            let value3 = useHook(deferredHook)

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
            let value1 = useHook(hook1)
            useHook(hook2)
            let value3 = useHook(hook3)
            let value4 = useHook(hook4)

            XCTAssertEqual(value1, 1)
            XCTAssertEqual(value3, 1)
            XCTAssertEqual(value4, 1)
        }

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            let value1 = useHook(hook1)
            let value3 = useHook(hook3)
            let value4 = useHook(hook4)

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
            let value1 = useHook(hook1)
            let value3 = useHook(hook3)
            let value4 = useHook(hook4)

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
            let value1 = useHook(hook1)
            let value2 = useHook(hook2)
            let value3 = useHook(hook3)

            XCTAssertEqual(value1, 1)
            XCTAssertEqual(value2, 1)
            XCTAssertEqual(value3, 1)
        }

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            // There is 1 hook
            let value1 = useHook(hook1)

            XCTAssertEqual(value1, 2)  // Works correctly
        }

        XCTAssertNil(hook1.disposedAt)
        XCTAssertEqual(hook2.disposedAt, 2)
        XCTAssertEqual(hook3.disposedAt, 1)
        XCTAssertEqual(disposeCounter.count, 2)

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            let value1 = useHook(hook1)
            let value2 = useHook(hook2)
            let value3 = useHook(hook3)

            XCTAssertEqual(value1, 3)  // Works correctly
            XCTAssertEqual(value2, 1)  // Previous state is initialized
            XCTAssertEqual(value3, 1)  // Previous state is initialized
        }

        dispatcher.scoped(disablesAssertion: true, environment: EnvironmentValues()) {
            let value1 = useHook(hook1)
            let value2 = useHook(hook2)
            let value3 = useHook(hook3)

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
                _ = useHook(hook1)
                _ = useHook(hook2)
            }

        XCTAssertEqual(disposeCounter.count, 0)

        dispatcher = nil

        XCTAssertEqual(disposeCounter.count, 2)
        XCTAssertEqual(hook1.disposedAt, 2)
        XCTAssertEqual(hook2.disposedAt, 1)
    }
}
