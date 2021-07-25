import SwiftUI

/// A hook to use a `Binding<State>` wrapping current state to be updated by setting a new state to `wrappedValue`.
/// Triggers a view update when the state has been changed.
///
///     let count = useState(0)
///     count.wrappedValue = 123
///
/// - Parameter initialState: An initial state.
/// - Returns: A `Binding<State>` wrapping current state.
public func useState<State>(_ initialState: State) -> Binding<State> {
    useHook(StateHook(initialState: initialState))
}

internal struct StateHook<State>: Hook {
    let initialState: State
    let computation = HookComputation.once

    func makeState() -> Ref {
        Ref(initialState: initialState)
    }

    func makeValue(coordinator: Coordinator) -> Binding<State> {
        Binding(
            get: { [state = coordinator.state.state] in
                state
            },
            set: { newState in
                coordinator.state.state = newState
                coordinator.updateView()
            }
        )
    }
}

internal extension StateHook {
    final class Ref {
        var state: State

        init(initialState: State) {
            state = initialState
        }
    }
}
