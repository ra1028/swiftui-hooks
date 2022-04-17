/// A hook to use the most recent phase of the passed non-throwing asynchronous operation, and a `perform` function to call the it at arbitrary timing.
///
///     let (phase, perform) = useAsyncPerform {
///         try! await URLSession.shared.data(from: url)
///     }
///
/// - Parameter operation: A closure that produces a resulting value asynchronously.
/// - Returns: A tuple of the most recent async phase and its perform function.
@discardableResult
public func useAsyncPerform<Output>(
    _ operation: @escaping @MainActor () async -> Output
) -> (
    phase: AsyncPhase<Output, Never>,
    perform: @MainActor () async -> Void
) {
    useHook(AsyncPerformHook(operation: operation))
}

/// A hook to use the most recent phase of the passed throwing asynchronous operation, and a `perform` function to call the it at arbitrary timing.
///
///     let (phase, perform) = useAsyncPerform {
///         try await URLSession.shared.data(from: url)
///     }
///
/// - Parameter operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsyncPerform<Output>(
    _ operation: @escaping @MainActor () async throws -> Output
) -> (
    phase: AsyncPhase<Output, Error>,
    perform: @MainActor () async -> Void
) {
    useHook(AsyncThrowingPerformHook(operation: operation))
}

internal struct AsyncPerformHook<Output>: Hook {
    let updateStrategy: HookUpdateStrategy? = .once
    let operation: @MainActor () async -> Output

    func makeState() -> State {
        State()
    }

    func value(coordinator: Coordinator) -> (
        phase: AsyncPhase<Output, Never>,
        perform: @MainActor () async -> Void
    ) {
        (
            phase: coordinator.state.phase,
            perform: {
                guard !coordinator.state.isDisposed else {
                    return
                }

                coordinator.state.phase = .running
                coordinator.updateView()

                let output = await operation()

                if !Task.isCancelled {
                    coordinator.state.phase = .success(output)
                    coordinator.updateView()
                }
            }
        )
    }

    func dispose(state: State) {
        state.isDisposed = true
    }
}

internal extension AsyncPerformHook {
    final class State {
        var phase = AsyncPhase<Output, Never>.pending
        var isDisposed = false
    }
}

internal struct AsyncThrowingPerformHook<Output>: Hook {
    let updateStrategy: HookUpdateStrategy? = .once
    let operation: @MainActor () async throws -> Output

    func makeState() -> State {
        State()
    }

    func value(coordinator: Coordinator) -> (
        phase: AsyncPhase<Output, Error>,
        perform: @MainActor () async -> Void
    ) {
        (
            phase: coordinator.state.phase,
            perform: {
                guard !coordinator.state.isDisposed else {
                    return
                }

                coordinator.state.phase = .running
                coordinator.updateView()

                let phase: AsyncPhase<Output, Error>

                do {
                    let output = try await operation()
                    phase = .success(output)
                }
                catch {
                    phase = .failure(error)
                }

                if !Task.isCancelled {
                    coordinator.state.phase = phase
                    coordinator.updateView()
                }
            }
        )
    }

    func dispose(state: State) {
        state.isDisposed = true
    }
}

internal extension AsyncThrowingPerformHook {
    final class State {
        var phase = AsyncPhase<Output, Error>.pending
        var isDisposed = false
    }
}
