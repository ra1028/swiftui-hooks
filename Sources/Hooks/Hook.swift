/// `Hook` manages the state and overall behavior of a hook. It has lifecycles to manage the state and when to compute the value.
/// It must be immutable, and should not have any state in itself, but should perform appropriate operations on the state managed by the internal system passed to lifecycle functions.
///
/// Use it when your custom hook becomes too complex can not be made with existing hooks composition.
public protocol Hook {
    /// The type of state that preserves the value computed by this hook.
    associatedtype State = Void

    /// The type of value that this hook computes.
    associatedtype Value

    /// The type of contextual information about the state of the hook.
    typealias Coordinator = HookCoordinator<Self>

    /// A strategy that determines when to update the state.
    var updateStrategy: HookUpdateStrategy? { get }

    /// Indicates whether the value should be updated after all hooks have been evaluated.
    var shouldDeferredUpdate: Bool { get }

    /// Returns a initial state of this hook.
    /// Internal system calls this function to create a state at first time each hook is evaluated.
    func makeState() -> State

    /// Updates the state when the `updateStrategy` determines that an update is necessary.
    /// - Parameter coordinator: A contextual information about the state of the hook.
    func updateState(coordinator: Coordinator)

    /// Returns a value which is returned when this hook is called.
    /// - Parameter coordinator: A contextual information about the state of the hook.
    func value(coordinator: Coordinator) -> Value

    /// Dispose of the state and interrupt running asynchronous operation.
    func dispose(state: State)
}

public extension Hook {
    /// Indicates whether the value should be updated after other hooks have been updated.
    /// Default is `false`.
    var shouldDeferredUpdate: Bool { false }

    /// Updates the state when the `updateStrategy` determines that an update is necessary.
    /// Does not do anything by default.
    /// - Parameter coordinator: A contextual information about the state of the hook.
    func updateState(coordinator: Coordinator) {}

    /// Dispose of the state and interrupt running asynchronous operation.
    /// Does not do anything by default.
    func dispose(state: State) {}
}

public extension Hook where State == Void {
    /// Returns a initial state of this hook.
    /// Internal system calls this function to create a state at first time each hook is evaluated.
    /// Default is Void.
    func makeState() -> State { () }
}

public extension Hook where Value == Void {
    /// Returns a value for each hook call.
    /// Default is Void.
    /// - Parameter coordinator: A contextual information about the state of the hook.
    func value(coordinator: Coordinator) {}
}
