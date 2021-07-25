import Combine
import Hooks
import SwiftUI

public final class HookTester<Parameter, Value> {
    public private(set) var value: Value
    public private(set) var valueHistory: [Value]

    private var currentParameter: Parameter
    private let hook: (Parameter) -> Value
    private let dispatcher = HookDispatcher()
    private var scopeValues = ScopeValues()
    private var cancellable: AnyCancellable?

    public init(
        _ initialParameter: Parameter,
        _ hook: @escaping (Parameter) -> Value,
        scope: (ScopeValues) -> ScopeValues = { $0 }
    ) {
        self.currentParameter = initialParameter
        self.hook = hook
        self.scopeValues = scope(scopeValues)
        self.value = dispatcher.scoped(
            environment: scopeValues.environment,
            { hook(initialParameter) }
        )
        self.valueHistory = [value]
        self.cancellable = dispatcher.objectWillChange
            .sink(receiveValue: { [weak self] in
                self?.rerender()
            })
    }

    public convenience init(
        _ hook: @escaping (Parameter) -> Value,
        scope: (ScopeValues) -> ScopeValues = { $0 }
    ) where Parameter == Void {
        self.init((), hook, scope: scope)
    }

    public func rerender(_ parameter: Parameter) {
        value = dispatcher.scoped(
            environment: scopeValues.environment,
            { hook(parameter) }
        )
        valueHistory.append(value)
        currentParameter = parameter
    }

    public func rerender() {
        rerender(currentParameter)
    }

    public func unmount() {
        dispatcher.disposeAll()
    }
}

public extension HookTester {
    struct ScopeValues {
        internal var environment = EnvironmentValues()

        private func mutating(_ body: (inout Self) -> Void) -> Self {
            var container = self
            body(&container)
            return container
        }

        public func environment<V>(
            _ keyPath: WritableKeyPath<EnvironmentValues, V>,
            _ value: V
        ) -> Self {
            mutating { $0.environment[keyPath: keyPath] = value }
        }

        public func context<V>(
            _ context: Context<V>.Type,
            _ value: V
        ) -> Self {
            mutating { $0.environment[context] = value }
        }
    }
}
