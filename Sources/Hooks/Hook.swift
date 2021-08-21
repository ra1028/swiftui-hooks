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

    var updateStrategy: HookUpdateStrategy? { get }

    /// Indicates whether the value should be computed after all hooks have been evaluated.
    var shouldDeferredCompute: Bool { get }

    /// Returns a initial state of this hook.
    /// Internal system calls this function to create a state at first time each hook is evaluated.
    func makeState() -> State

    /// Returns a value for each hook call.
    /// - Parameter coordinator: A contextual information about the state of the hook.
    func makeValue(coordinator: Coordinator) -> Value

    /// Compute the value and store it to the state of the hook.
    /// The timing at which this function is called is specified by `computation`.
    /// - Parameter coordinator: A contextual information about the state of the hook.
    func compute(coordinator: Coordinator)

    /// Dispose of the state and interrupt running asynchronous operation.
    func dispose(state: State)
}

public extension Hook {
    /// Indicates whether the value should be computed after all hooks have been evaluated.
    /// Default is `false`.
    var shouldDeferredCompute: Bool { false }

    /// Compute the value and store it to the state of the hook.
    /// The timing at which this function is called is specified by `computation`.
    /// Does not do anything by default.
    /// - Parameter coordinator: A contextual information about the state of the hook.
    func compute(coordinator: Coordinator) {}

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
    func makeValue(coordinator: Coordinator) {}
}
