import SwiftUI

/// Contextual information about the state of the hook.
public struct HookCoordinator<H: Hook> {
    /// The state of the hook stored in the scope.
    public let state: H.State

    /// The current environment of the scope.
    public let environment: EnvironmentValues

    /// A function that to update the content of the nearest scope.
    public let updateView: () -> Void

    /// Create a new coordinator.
    /// - Parameters:
    ///   - state: The state of the hook stored in the scope.
    ///   - environment: The current environment of the scope.
    ///   - updateView: A function that to update the content of the nearest scope.
    public init(
        state: H.State,
        environment: EnvironmentValues,
        updateView: @escaping () -> Void
    ) {
        self.state = state
        self.environment = environment
        self.updateView = updateView
    }
}
