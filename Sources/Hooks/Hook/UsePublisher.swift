import Combine

/// A hook to use the most recent phase of asynchronous operation of the passed publisher.
/// The publisher will be subscribed at the first computation and will be re-subscribed according to the strategy specified with the passed `computation`.
/// Triggers a view update when the asynchronous phase has been changed.
///
///     let phase = usePublisher(.once) {
///         URLSession.shared.dataTaskPublisher(for: url)
///     }
///
/// - Parameters:
///   - computation: A computation strategy that to determine when to subscribe the effect function again.
///   - makePublisher: A closure that to create a new publisher to be subscribed.
/// - Returns: A most recent publisher phase.
@discardableResult
public func usePublisher<P: Publisher>(
    _ updateStrategy: HookUpdateStrategy,
    _ makePublisher: @escaping () -> P
) -> AsyncPhase<P.Output, P.Failure> {
    useHook(
        PublisherHook(
            updateStrategy: updateStrategy,
            makePublisher: makePublisher
        )
    )
}

private struct PublisherHook<P: Publisher>: Hook {
    let updateStrategy: HookUpdateStrategy?
    let makePublisher: () -> P

    func makeState() -> State {
        State()
    }

    func updateState(coordinator: Coordinator) {
        coordinator.state.phase = .running
        coordinator.state.cancellable = makePublisher()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        coordinator.state.phase = .failure(error)

                    case .finished:
                        break
                    }
                    coordinator.updateView()
                },
                receiveValue: { output in
                    coordinator.state.phase = .success(output)
                    coordinator.updateView()
                }
            )
    }

    func value(coordinator: Coordinator) -> AsyncPhase<P.Output, P.Failure> {
        coordinator.state.phase
    }

    func dispose(state: State) {
        state.cancellable = nil
    }
}

private extension PublisherHook {
    final class State {
        var phase = AsyncPhase<P.Output, P.Failure>.pending
        var cancellable: AnyCancellable?
    }
}
