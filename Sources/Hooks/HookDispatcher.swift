import Combine
import SwiftUI

/// A class that manages list of states of hooks used inside `HookDispatcher.scoped(disablesAssertion:environment:_)`.
public final class HookDispatcher: ObservableObject {
    internal private(set) static weak var current: HookDispatcher?

    /// A publisher that emits before the object has changed.
    public let objectWillChange = PassthroughSubject<(), Never>()

    private var records = LinkedList<HookRecordProtocol>()
    private var scopedState: ScopedHookState?

    /// Creates a new `HookDispatcher`.
    public init() {}

    deinit {
        disposeAll()
    }

    /// Disposes all hooks that already managed with this instance.
    public func disposeAll() {
        for record in records.reversed() {
            record.element.dispose()
        }

        records = LinkedList()
    }

    /// Returns given hooks value with managing its state and update it if needed.
    /// - Parameter hook: A hook to be used.
    /// - Returns: A value that provided from the given hook.
    public func use<H: Hook>(_ hook: H) -> H.Value {
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

            if hook.shouldDeferredUpdate {
                scopedState.deferredUpdateRecords.append(record)
            }
            else {
                hook.updateState(coordinator: coordinator)
            }

            return hook.value(coordinator: coordinator)
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

            if oldRecord.shouldUpdate(newHook: hook) {
                if hook.shouldDeferredUpdate {
                    scopedState.deferredUpdateRecords.append(newRecord)
                }
                else {
                    hook.updateState(coordinator: coordinator)
                }
            }

            return hook.value(coordinator: coordinator)
        }
        else {
            scopedState.assertRecordingFailure(hook: hook, record: record.element)

            // Fallback process for wrong usage.

            sweepRemainingRecords()

            return appendNew()
        }
    }

    /// Executes the given `body` function that needs `HookDispatcher` instance with managing hooks state.
    /// - Parameters:
    ///   - disablesAssertion: A Boolean value indicates whether to disable assertions of hooks rule.
    ///   - environment: A environment values that can be used for hooks used inside the `body`.
    ///   - body: A function that needs `HookDispatcher` and is executed inside.
    /// - Throws: Rethrows an error if the given function throws.
    /// - Returns: A result value that the given `body` function returns.
    public func scoped<Result>(
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

        scopedState.deferredUpdate()
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
    var deferredUpdateRecords = LinkedList<HookRecordProtocol>()

    init(
        disablesAssertion: Bool,
        environment: EnvironmentValues,
        currentRecord: LinkedList<HookRecordProtocol>.Node?
    ) {
        self.disablesAssertion = disablesAssertion
        self.environment = environment
        self.currentRecord = currentRecord
    }

    func deferredUpdate() {
        for record in deferredUpdateRecords {
            record.element.updateState()
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

    func shouldUpdate<New: Hook>(newHook: New) -> Bool {
        guard let newStrategy = newHook.updateStrategy else {
            return true
        }

        return hook.updateStrategy?.dependency != newStrategy.dependency
    }

    func updateState() {
        hook.updateState(coordinator: coordinator)
    }

    func dispose() {
        hook.dispose(state: coordinator.state)
    }
}

private protocol HookRecordProtocol {
    var hookName: String { get }

    func state<H: Hook>(of hookType: H.Type) -> H.State?
    func shouldUpdate<New: Hook>(newHook: New) -> Bool
    func updateState()
    func dispose()
}
