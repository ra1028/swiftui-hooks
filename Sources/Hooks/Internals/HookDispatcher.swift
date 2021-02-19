import Combine
import SwiftUI

internal final class HookDispatcher: ObservableObject {
    private(set) static weak var current: HookDispatcher?

    private var records = LinkedList<HookRecordProtocol>()
    private var scopedState: ScopedHookState?

    let objectWillChange = PassthroughSubject<(), Never>()

    init() {}

    deinit {
        for record in records.reversed() {
            record.element.dispose()
        }
    }

    func use<H: Hook>(_ hook: H) -> H.Value {
        assertMainThread()

        guard let scopedState = scopedState else {
            fatalErrorHooksRules()
        }

        func makeCoordinator(state: H.State) -> HookCoordinator<H> {
            HookCoordinator(
                state: state,
                environment: scopedState.environment,
                updateView: objectWillChange.send
            )
        }

        func appendNew() -> H.Value {
            let state = hook.makeState()
            let coordinator = makeCoordinator(state: state)
            let record = HookRecord(hook: hook, coordinator: coordinator)

            scopedState.currentRecord = records.append(record)

            if hook.shouldDeferredCompute {
                scopedState.deferredComputeRecords.append(record)
            }
            else {
                hook.compute(coordinator: coordinator)
            }

            return hook.makeValue(coordinator: coordinator)
        }

        defer {
            scopedState.currentRecord = scopedState.currentRecord?.next
        }

        guard let record = scopedState.currentRecord else {
            return appendNew()
        }

        if let state = record.element.state(of: H.self) {
            let coordinator = makeCoordinator(state: state)
            let newRecord = HookRecord(hook: hook, coordinator: coordinator)
            let oldRecord = record.swap(element: newRecord)

            if oldRecord.shouldRecompute(for: hook) {
                if hook.shouldDeferredCompute {
                    scopedState.deferredComputeRecords.append(newRecord)
                }
                else {
                    hook.compute(coordinator: coordinator)
                }
            }

            return hook.makeValue(coordinator: coordinator)
        }
        else {
            scopedState.assertRecordingFailure(hook: hook, record: record.element)

            // Fallback process for wrong usage.

            sweepRemainingRecords()

            return appendNew()
        }
    }

    func scoped<Result>(
        disablesAssertion: Bool = false,
        environment: EnvironmentValues,
        _ body: () throws -> Result
    ) rethrows -> Result {
        assertMainThread()

        let previous = Self.current

        Self.current = self

        let scopedState = ScopedHookState(
            disablesAssertion: disablesAssertion,
            environment: environment,
            currentRecord: records.first
        )

        self.scopedState = scopedState

        let value = try body()

        scopedState.deferredCompute()
        scopedState.assertConsumedState()
        sweepRemainingRecords()

        self.scopedState = nil

        Self.current = previous

        return value
    }
}

private extension HookDispatcher {
    func sweepRemainingRecords() {
        guard let scopedState = scopedState, let currentRecord = scopedState.currentRecord else {
            return
        }

        let remaining = records.dropSuffix(from: currentRecord)

        for record in remaining.reversed() {
            record.element.dispose()
        }

        scopedState.currentRecord = records.last
    }
}

private final class ScopedHookState {
    let disablesAssertion: Bool
    let environment: EnvironmentValues
    var currentRecord: LinkedList<HookRecordProtocol>.Node?
    var deferredComputeRecords = LinkedList<HookRecordProtocol>()

    init(
        disablesAssertion: Bool,
        environment: EnvironmentValues,
        currentRecord: LinkedList<HookRecordProtocol>.Node?
    ) {
        self.disablesAssertion = disablesAssertion
        self.environment = environment
        self.currentRecord = currentRecord
    }

    func deferredCompute() {
        for record in deferredComputeRecords {
            record.element.compute()
        }
    }

    func assertConsumedState() {
        guard !disablesAssertion else {
            return
        }

        assert(
            currentRecord == nil,
            """
            Some Hooks are no longer used from the previous evaluation.
            Hooks relies on the order in which they are called. Do not call Hooks inside loops, conditions, or nested functions.

            - SeeAlso: https://reactjs.org/docs/hooks-rules.html#only-call-hooks-at-the-top-level
            """
        )
    }

    func assertRecordingFailure<H: Hook>(hook: H, record: HookRecordProtocol) {
        guard !disablesAssertion else {
            return
        }

        assertionFailure(
            """
            The type of Hooks did not match with the type evaluated in the previous evaluation.
            Previous hook: \(record.hookName)
            Current hook: \(type(of: hook))
            Hooks relies on the order in which they are called. Do not call Hooks inside loops, conditions, or nested functions.

            - SeeAlso: https://reactjs.org/docs/hooks-rules.html#only-call-hooks-at-the-top-level
            """
        )
    }
}

private struct HookRecord<H: Hook>: HookRecordProtocol {
    let hook: H
    let coordinator: HookCoordinator<H>

    var hookName: String {
        String(describing: type(of: hook))
    }

    func state<H: Hook>(of hookType: H.Type) -> H.State? {
        coordinator.state as? H.State
    }

    func shouldRecompute<New: Hook>(for newHook: New) -> Bool {
        hook.computation.shouldRecompute(for: newHook.computation)
    }

    func compute() {
        hook.compute(coordinator: coordinator)
    }

    func dispose() {
        hook.dispose(state: coordinator.state)
    }
}

private protocol HookRecordProtocol {
    var hookName: String { get }

    func state<H: Hook>(of hookType: H.Type) -> H.State?
    func shouldRecompute<New: Hook>(for newHook: New) -> Bool
    func compute()
    func dispose()
}
