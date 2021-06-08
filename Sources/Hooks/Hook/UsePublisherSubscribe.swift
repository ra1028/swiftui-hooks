import Combine

/// A hook to use the most recent status of asynchronous operation of the passed publisher, and a `subscribe` function to be started to subscribe arbitrary timing.
/// Update the view with the asynchronous status change.
///
///     let (status, subscribe) = usePublisherSubscribe {
///         URLSession.shared.dataTaskPublisher(for: url)
///     }
///
/// - Parameter makePublisher: A closure that to create a new publisher to be subscribed.
/// - Returns: A most recent publisher status.
@discardableResult
public func usePublisherSubscribe<P: Publisher>(
    _ makePublisher: @escaping () -> P
) -> (
    status: AsyncStatus<P.Output, P.Failure>,
    subscribe: () -> Void
) {
    useHook(PublisherSubscribeHook(makePublisher: makePublisher))
}

internal struct PublisherSubscribeHook<P: Publisher>: Hook {
    let makePublisher: () -> P
    let computation = HookComputation.once

    func makeState() -> State {
        State()
    }

    func makeValue(coordinator: Coordinator) -> (
        status: AsyncStatus<P.Output, P.Failure>,
        subscribe: () -> Void
    ) {
        (
            status: coordinator.state.status,
            subscribe: {
                assertMainThread()

                guard !coordinator.state.isDisposed else {
                    return
                }

                coordinator.state.cancellable = makePublisher()
                    .handleEvents(
                        receiveSubscription: { _ in
                            coordinator.state.status = .running
                            coordinator.updateView()
                        }
                    )
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case .failure(let error):
                                coordinator.state.status = .failure(error)
                                coordinator.updateView()

                            case .finished:
                                break
                            }
                        },
                        receiveValue: { output in
                            coordinator.state.status = .success(output)
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

internal extension PublisherSubscribeHook {
    final class State {
        var status = AsyncStatus<P.Output, P.Failure>.pending
        var isDisposed = false
        var cancellable: AnyCancellable?
    }
}
