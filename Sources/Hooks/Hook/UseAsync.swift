#if swift(>=5.5)

@available(iOS 15.0, *)
public func useAsync<Output>(
    _ computation: HookComputation,
    _ operation: @escaping () async -> Output
) -> AsyncStatus<Output, Never> {
    useHook(
        AsyncHook(
            computation: computation,
            operation: operation
        )
    )
}

@available(iOS 15.0, *)
public func useAsync<Output>(
    _ computation: HookComputation,
    _ operation: @escaping () async throws -> Output
) -> AsyncStatus<Output, Error> {
    useHook(
        AsyncThrowingHook(
            computation: computation,
            operation: operation
        )
    )
}

@available(iOS 15.0, *)
internal struct AsyncHook<Output>: Hook {
    let computation: HookComputation
    let shouldDeferredCompute = true
    let operation: () async -> Output

    func makeState() -> State {
        State()
    }

    func makeValue(coordinator: Coordinator) -> AsyncStatus<Output, Never> {
        coordinator.state.status
    }

    func compute(coordinator: Coordinator) {
        coordinator.state.taskHandle = async { @MainActor in
            coordinator.state.status = .running
            coordinator.updateView()

            let output = await operation()
            coordinator.state.status = .success(output)
            coordinator.updateView()
        }
    }

    func dispose(state: State) async {
        state.taskHandle?.cancel()
        state.taskHandle = nil
    }
}

@available(iOS 15.0, *)
internal extension AsyncHook {
    final class State {
        var status = AsyncStatus<Output, Never>.pending
        var taskHandle: Task.Handle<Void, Never>?
    }
}

@available(iOS 15.0, *)
internal struct AsyncThrowingHook<Output>: Hook {
    let computation: HookComputation
    let shouldDeferredCompute = true
    let operation: () async throws -> Output

    func makeState() -> State {
        State()
    }

    func makeValue(coordinator: Coordinator) -> AsyncStatus<Output, Error> {
        coordinator.state.status
    }

    func compute(coordinator: Coordinator) {
        coordinator.state.taskHandle = async { @MainActor in
            coordinator.state.status = .running
            coordinator.updateView()

            do {
                let output = try await operation()
                coordinator.state.status = .success(output)
            }
            catch {
                coordinator.state.status = .failure(error)
            }

            coordinator.updateView()
        }
    }

    func dispose(state: State) async {
        state.taskHandle?.cancel()
        state.taskHandle = nil
    }
}

@available(iOS 15.0, *)
internal extension AsyncThrowingHook {
    final class State {
        var status = AsyncStatus<Output, Error>.pending
        var taskHandle: Task.Handle<Void, Never>?
    }
}

#endif
