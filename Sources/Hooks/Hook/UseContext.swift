/// A hook to use current context value that is provided by `Context<T>.Provider`.
/// The purpose is identical to use `Context<T>.Consumer`.
///
///     typealias CounterContext = Context<Binding<Int>>
///
///     let count = useContext(CounterContext.self)
///
/// - Parameter context: The type of context.
/// - Returns: A value that provided by provider from upstream of the view tree.
public func useContext<T>(_ context: Context<T>.Type) -> T {
    useHook(ContextHook(context: context))
}

private struct ContextHook<T>: Hook {
    let context: Context<T>.Type
    let updateStrategy: HookUpdateStrategy? = .once

    func value(coordinator: Coordinator) -> T {
        guard let value = coordinator.environment[context] else {
            fatalError(
                """
                No context value of type \(context) found.
                A \(context).Provider.init(value:content:) is missing as an ancestor of the consumer.

                - SeeAlso: https://reactjs.org/docs/context.html#contextprovider
                """
            )
        }

        return value
    }
}
