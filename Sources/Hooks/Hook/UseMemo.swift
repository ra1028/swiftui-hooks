/// A hook to use memoized value preserved until it is re-computed at the timing specified with the `computation`
///
///     let random = useMemo(.once) {
///         Int.random(in: 0...100)
///     }
///
/// - Parameters:
///   - computation: A computation strategy that to determine when to re-compute the value.
///   - makeValue: A closure that to create a new value.
/// - Returns: A memoized value.
public func useMemo<Value>(
    _ computation: HookComputation,
    _ makeValue: @escaping () -> Value
) -> Value {
    MemoHook(computation: computation, makeValue: makeValue).use()
}

internal struct MemoHook<Value>: Hook {
    let computation: HookComputation
    let makeValue: () -> Value

    func makeState() -> State {
        State()
    }

    func makeValue(coordinator: Coordinator) -> Value {
        coordinator.state.value ?? makeValue()
    }

    func compute(coordinator: Coordinator) {
        coordinator.state.value = makeValue()
    }
}

internal extension MemoHook {
    final class State {
        var value: Value?
    }
}
