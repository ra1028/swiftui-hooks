import Combine

/// A hook to use the most recent phase of asynchronous operation of the passed publisher, and a `subscribe` function to be started to subscribe arbitrary timing.
/// Update the view with the asynchronous phase change.
///
///     let (phase, subscribe) = usePublisherSubscribe {
///         URLSession.shared.dataTaskPublisher(for: url)
///     }
///
/// - Parameter makePublisher: A closure that to create a new publisher to be subscribed.
/// - Returns: A most recent publisher phase.
@discardableResult
public func usePublisherSubscribe<P: Publisher>(
    _ makePublisher: @escaping () -> P
) -> (
    phase: AsyncPhase<P.Output, P.Failure>,
    subscribe: () -> Void
) {
    useHook(PublisherSubscribeHook(makePublisher: makePublisher))
}

private struct PublisherSubscribeHook<P: Publisher>: Hook {
    let makePublisher: () -> P
    let computation = HookComputation.once

    func makeState() -> State {
        State()
    }

    func makeValue(coordinator: Coordinator) -> (
        phase: AsyncPhase<P.Output, P.Failure>,
        subscribe: () -> Void
    ) {
        (
            phase: coordinator.state.phase,
            subscribe: {
                assertMainThread()

                guard !coordinator.state.isDisposed else {
                    return
                }

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
                                coordinator.updateView()

                            case .finished:
                                break
                            }
                        },
                        receiveValue: { output in
                            coordinator.state.phase = .success(output)
                            coordinator.updateView()
                        }
                    )
            }
        )
    }

    func dispose(state: State) {
        state.isDisposed = true
        state.cancellable = nil
    }
}

private extension PublisherSubscribeHook {
    final class State {
        var phase = AsyncPhase<P.Output, P.Failure>.pending
        var isDisposed = false
        var cancellable: AnyCancellable?
    }
}
