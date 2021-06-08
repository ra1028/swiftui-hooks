/// A hook to use a side effect function that is called the number of times according to the strategy specified by `computation`.
/// Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.
/// Note that the execution is deferred until after all the hooks have been evaluated.
///
///     useEffect(.once) {
///         print("View is mounted")
///
///         return {
///             print("View is unmounted")
///         }
///     }
///
/// - Parameters:
///   - computation: A computation strategy that to determine when to call the effect function again.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useEffect(
    _ computation: HookComputation,
    _ effect: @escaping () -> (() -> Void)?
) {
    useHook(
        EffectHook(
            computation: computation,
            shouldDeferredCompute: true,
            effect: effect
        )
    )
}

internal struct EffectHook: Hook {
    let computation: HookComputation
    let shouldDeferredCompute: Bool
    let effect: () -> (() -> Void)?

    func makeState() -> State {
        State()
    }

    func compute(coordinator: Coordinator) {
        coordinator.state.cleanup = effect()
    }

    func dispose(state: State) {
        state.cleanup = nil
    }
}

internal extension EffectHook {
    final class State {
        var cleanup: (() -> Void)? {
            didSet { oldValue?() }
        }
    }
}
