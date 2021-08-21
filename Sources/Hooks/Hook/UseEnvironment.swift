import SwiftUI

/// A hook to use environment value passed through the view tree without `@Environment` property wrapper.
///
///     let colorScheme = useEnvironment(\.colorScheme)
///
/// - Parameter keyPath: A key path to a specific resulting value.
/// - Returns: A environment value from the view's environment.
public func useEnvironment<Value>(_ keyPath: KeyPath<EnvironmentValues, Value>) -> Value {
    useHook(EnvironmentHook(keyPath: keyPath))
}

private struct EnvironmentHook<Value>: Hook {
    let keyPath: KeyPath<EnvironmentValues, Value>
    let updateStrategy: HookUpdateStrategy? = .once

    func value(coordinator: Coordinator) -> Value {
        coordinator.environment[keyPath: keyPath]
    }
}
