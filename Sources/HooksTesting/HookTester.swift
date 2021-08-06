import Combine
import Hooks
import SwiftUI

/// A testing tool that simulates the behaviors of a given hook on a view
/// and manages the resulting values.
public final class HookTester<Parameter, Value> {
    /// The latest result value that the given Hook was executed.
    public private(set) var value: Value

    /// A history of the resulting values of the given Hook being executed.
    public private(set) var valueHistory: [Value]

    private var currentParameter: Parameter
    private let hook: (Parameter) -> Value
    private let dispatcher = HookDispatcher()
    private let environment: EnvironmentValues
    private var cancellable: AnyCancellable?

    /// Creates a new tester that simulates the behavior of a given hook on a view
    /// and manages the resulting values.
    /// - Parameters:
    ///   - initialParameter: An initial value of the parameter passed when calling the hook.
    ///   - hook: A closure for calling the hook under test.
    ///   - environment: A closure for mutating an `EnvironmentValues` that to be used for testing environment.
    public init(
        _ initialParameter: Parameter,
        _ hook: @escaping (Parameter) -> Value,
        environment: (inout EnvironmentValues) -> Void = { _ in }
    ) {
        var environmentValues = EnvironmentValues()
        environment(&environmentValues)

        self.currentParameter = initialParameter
        self.hook = hook
        self.value = dispatcher.scoped(
            environment: environmentValues,
            { hook(initialParameter) }
        )
        self.valueHistory = [value]
        self.environment = environmentValues
        self.cancellable = dispatcher.objectWillChange
            .sink(receiveValue: { [weak self] in
                self?.update()
            })
    }

    /// Creates a new tester that simulates the behavior of a given hook on a view
    /// and manages the resulting values.
    /// - Parameters:
    ///   - hook: A closure for running the hook under test.
    ///   - environment: A closure for mutating an `EnvironmentValues` that to be used for testing environment.
    public convenience init(
        _ hook: @escaping (Parameter) -> Value,
        environment: (inout EnvironmentValues) -> Void = { _ in }
    ) where Parameter == Void {
        self.init((), hook, environment: environment)
    }

    /// Simulate a view update and re-call the hook under test with a given parameter.
    /// - Parameter parameter: A parameter value passed when calling the hook.
    public func update(with parameter: Parameter) {
        value = dispatcher.scoped(
            environment: environment,
            { hook(parameter) }
        )
        valueHistory.append(value)
        currentParameter = parameter
    }

    /// Simulate a view update and re-call the hook under test with the latest parameter that already applied.
    public func update() {
        update(with: currentParameter)
    }

    /// Simulate view unmounting and disposes the hook under test.
    public func dispose() {
        dispatcher.disposeAll()
    }
}
