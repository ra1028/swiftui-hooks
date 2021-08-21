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
    _ updateStrategy: HookUpdateStrategy,
    _ makeValue: @escaping () -> Value
) -> Value {
    useHook(
        MemoHook(
            updateStrategy: updateStrategy,
            makeValue: makeValue
        )
    )
}

private struct MemoHook<Value>: Hook {
    let updateStrategy: HookUpdateStrategy?
    let makeValue: () -> Value

    func makeState() -> State {
        State()
    }

    func updateState(coordinator: Coordinator) {
        coordinator.state.value = makeValue()
    }

    func value(coordinator: Coordinator) -> Value {
        coordinator.state.value ?? makeValue()
    }
}

private extension MemoHook {
    final class State {
        var value: Value?
    }
}
