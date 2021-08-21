/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is disposed or when the side-effect function is called again.
/// Note that the execution is deferred until after ohter hooks have been updated.
///
///     useEffect {
///         print("Do side effects")
///
///         return {
///             print("Do cleanup")
///         }
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useEffect(
    _ updateStrategy: HookUpdateStrategy? = nil,
    _ effect: @escaping () -> (() -> Void)?
) {
    useHook(
        EffectHook(
            updateStrategy: updateStrategy,
            shouldDeferredUpdate: true,
            effect: effect
        )
    )
}

/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.
/// The signature is identical to `useEffect`, but this fires synchronously when the hook is called.
///
///     useLayoutEffect {
///         print("Do side effects")
///         return nil
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useLayoutEffect(
    _ updateStrategy: HookUpdateStrategy? = nil,
    _ effect: @escaping () -> (() -> Void)?
) {
    useHook(
        EffectHook(
            updateStrategy: updateStrategy,
            shouldDeferredUpdate: false,
            effect: effect
        )
    )
}

private struct EffectHook: Hook {
    let updateStrategy: HookUpdateStrategy?
    let shouldDeferredUpdate: Bool
    let effect: () -> (() -> Void)?

    func makeState() -> State {
        State()
    }

    func updateState(coordinator: Coordinator) {
        coordinator.state.cleanup = effect()
    }

    func dispose(state: State) {
        state.cleanup = nil
    }
}

private extension EffectHook {
    final class State {
        var cleanup: (() -> Void)? {
            didSet { oldValue?() }
        }
    }
}
