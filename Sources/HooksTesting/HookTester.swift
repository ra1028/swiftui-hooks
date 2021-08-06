import Combine
import Hooks
import SwiftUI

public final class HookTester<Parameter, Value> {
    public private(set) var value: Value
    public private(set) var valueHistory: [Value]

    private var currentParameter: Parameter
    private let hook: (Parameter) -> Value
    private let dispatcher = HookDispatcher()
    private let environment: EnvironmentValues
    private var cancellable: AnyCancellable?

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

    public convenience init(
        _ hook: @escaping (Parameter) -> Value,
        environment: (inout EnvironmentValues) -> Void = { _ in }
    ) where Parameter == Void {
        self.init((), hook, environment: environment)
    }

    public func update(with parameter: Parameter) {
        value = dispatcher.scoped(
            environment: environment,
            { hook(parameter) }
        )
        valueHistory.append(value)
        currentParameter = parameter
    }

    public func update() {
        update(with: currentParameter)
    }

    public func dispose() {
        dispatcher.disposeAll()
    }
}
