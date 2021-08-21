/// A hook to use a mutable ref object storing an arbitrary value.
/// The essential of this hook is that setting a value to `current` doesn't trigger a view update.
///
///     let value = useRef("text")
///     value.current = "new text"
///
/// - Parameter initialValue: A initial value that to initialize the ref object to be returned.
/// - Returns: A mutable ref object.
public func useRef<T>(_ initialValue: T) -> RefObject<T> {
    useHook(RefHook(initialValue: initialValue))
}

private struct RefHook<T>: Hook {
    let initialValue: T
    let updateStrategy: HookUpdateStrategy? = .once

    func makeState() -> RefObject<T> {
        RefObject(initialValue)
    }

    func makeValue(coordinator: Coordinator) -> RefObject<T> {
        coordinator.state
    }
}
