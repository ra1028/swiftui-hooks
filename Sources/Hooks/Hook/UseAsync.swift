/// A hook to use the most recent phase of asynchronous operation of the passed non-throwing function.
/// The function will be performed at the first update and will be re-performed according to the given `updateStrategy`.
///
///     let phase = useAsync(.once) {
///         try! await URLSession.shared.data(from: url)
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-perform the given function.
///   - operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsync<Output>(
    _ updateStrategy: HookUpdateStrategy,
    _ operation: @escaping () async -> Output
) -> AsyncPhase<Output, Never> {
    useHook(
        AsyncHook(
            updateStrategy: updateStrategy,
            operation: operation
        )
    )
}

/// A hook to use the most recent phase of asynchronous operation of the passed throwing function.
/// The function will be performed at the first update and will be re-performed according to the given `updateStrategy`.
///
///     let phase = useAsync(.once) {
///         try await URLSession.shared.data(from: url)
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-perform the given function.
///   - operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsync<Output>(
    _ updateStrategy: HookUpdateStrategy,
    _ operation: @escaping () async throws -> Output
) -> AsyncPhase<Output, Error> {
    useHook(
        AsyncThrowingHook(
            updateStrategy: updateStrategy,
            operation: operation
        )
    )
}

internal struct AsyncHook<Output>: Hook {
    let updateStrategy: HookUpdateStrategy?
    let operation: () async -> Output

    func makeState() -> State {
        State()
    }

    func value(coordinator: Coordinator) -> AsyncPhase<Output, Never> {
        coordinator.state.phase
    }

    func updateState(coordinator: Coordinator) {
        coordinator.state.phase = .running
        coordinator.state.task = Task { @MainActor in
            let output = await operation()

            if !Task.isCancelled {
                coordinator.state.phase = .success(output)
                coordinator.updateView()
            }
        }
    }

    func dispose(state: State) {
        state.task = nil
    }
}

internal extension AsyncHook {
    final class State {
        var phase = AsyncPhase<Output, Never>.pending
        var task: Task<Void, Never>? {
            didSet {
                oldValue?.cancel()
            }
        }
    }
}

internal struct AsyncThrowingHook<Output>: Hook {
    let updateStrategy: HookUpdateStrategy?
    let operation: () async throws -> Output

    func makeState() -> State {
        State()
    }

    func value(coordinator: Coordinator) -> AsyncPhase<Output, Error> {
        coordinator.state.phase
    }

    func updateState(coordinator: Coordinator) {
        coordinator.state.phase = .running
        coordinator.state.task = Task { @MainActor in
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
    }

    func dispose(state: State) {
        state.task = nil
    }
}

internal extension AsyncThrowingHook {
    final class State {
        var phase = AsyncPhase<Output, Error>.pending
        var task: Task<Void, Never>? {
            didSet {
                oldValue?.cancel()
            }
        }
    }
}
