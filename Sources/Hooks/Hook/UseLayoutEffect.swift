/// A hook to use a side effect function that is called the number of times according to the strategy specified by `computation`.
/// Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.
/// The signature is identical to `useEffect`, but this fires synchronously when the hook is called.
///
///     useEffect(.always) {
///         print("View is being evaluated")
///         return nil
///     }
///
/// - Parameters:
///   - computation: A computation strategy that to determine when to call the effect function again.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useLayoutEffect(
    _ computation: HookComputation,
    _ effect: @escaping () -> (() -> Void)?
) {
    useHook(
        EffectHook(
            computation: computation,
            shouldDeferredCompute: false,
            effect: effect
        )
    )
}
