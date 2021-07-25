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
    _ computation: HookComputation,
    _ makePublisher: @escaping () -> P
) -> AsyncPhase<P.Output, P.Failure> {
    useHook(
        PublisherHook(
            computation: computation,
            makePublisher: makePublisher
        )
    )
}

internal struct PublisherHook<P: Publisher>: Hook {
    let computation: HookComputation
    let shouldDeferredCompute = true
    let makePublisher: () -> P

    func makeState() -> State {
        State()
    }

    func makeValue(coordinator: Coordinator) -> AsyncPhase<P.Output, P.Failure> {
        coordinator.state.phase
    }

    func compute(coordinator: Coordinator) {
        coordinator.state.cancellable = makePublisher()
            .handleEvents(
                receiveSubscription: { _ in
                    coordinator.state.phase = .running
                    coordinator.updateView()
                }
            )
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

    func dispose(state: State) {
        state.cancellable = nil
    }
}

internal extension PublisherHook {
    final class State {
        var phase = AsyncPhase<P.Output, P.Failure>.pending
        var cancellable: AnyCancellable?
    }
}
