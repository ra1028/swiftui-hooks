public func useAsyncPerform<Output>(
    _ operation: @escaping @MainActor () async -> Output
) -> (
    phase: AsyncPhase<Output, Never>,
    perform: @MainActor () async -> Void
) {
    useHook(AsyncPerformHook(operation: operation))
}

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
    let shouldDeferredCompute = true
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

                coordinator.state.task = Task {
                    coordinator.state.phase = .running
                    coordinator.updateView()

                    let output = await operation()
                    coordinator.state.phase = .success(output)
                    coordinator.updateView()
                }
            }
        )
    }

    func dispose(state: State) async {
        state.isDisposed = true
        state.task?.cancel()
        state.task = nil
    }
}

internal extension AsyncPerformHook {
    final class State {
        var phase = AsyncPhase<Output, Never>.pending
        var isDisposed = false
        var task: Task<Void, Never>?
    }
}

internal struct AsyncThrowingPerformHook<Output>: Hook {
    let updateStrategy: HookUpdateStrategy? = .once
    let shouldDeferredCompute = true
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

                coordinator.state.task = Task {
                    coordinator.state.phase = .running
                    coordinator.updateView()

                    do {
                        let output = try await operation()
                        coordinator.state.phase = .success(output)
                    }
                    catch {
                        coordinator.state.phase = .failure(error)
                    }

                    coordinator.updateView()
                }
            }
        )
    }

    func dispose(state: State) async {
        state.isDisposed = true
        state.task?.cancel()
        state.task = nil
    }
}

internal extension AsyncThrowingPerformHook {
    final class State {
        var phase = AsyncPhase<Output, Error>.pending
        var isDisposed = false
        var task: Task<Void, Never>?
    }
}
