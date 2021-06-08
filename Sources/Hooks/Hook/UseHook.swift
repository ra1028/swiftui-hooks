/// Register the hook to the view and returns its value.
/// Must be called at the function top level within scope of the `HookScope` or the HookView.hookBody`.
///
///     struct CustomHook: Hook {
///         ...
///     }
///
///     let value = useHook(CustomHook())
///
/// - Parameter hook: A hook to be used.
/// - Returns: A value that this hook provides.
public func useHook<H: Hook>(_ hook: H) -> H.Value {
    assertMainThread()

    guard let dispatcher = HookDispatcher.current else {
        fatalErrorHooksRules()
    }

    return dispatcher.use(hook)
}
