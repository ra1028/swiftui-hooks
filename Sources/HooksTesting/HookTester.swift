import Combine
import Hooks
import SwiftUI

public final class HookTester<Parameter, Value> {
    public private(set) var value: Value
    public private(set) var valueHistory: [Value]

    private let render: (Parameter) -> Value
    private let dispose: () -> Void
    private var currentParameter: Parameter
    private var cancellable: AnyCancellable?

    public init(
        disablesAssertion: Bool = false,
        environment: EnvironmentValues = EnvironmentValues(),
        _ initialParameter: Parameter,
        _ hook: @escaping (Parameter) -> Value
    ) {
        let dispatcher = HookDispatcher()
        self.render = { parameter in
            dispatcher.scoped(
                disablesAssertion: disablesAssertion,
                environment: environment,
                { hook(parameter) }
            )
        }
        self.dispose = dispatcher.disposeAll
        self.currentParameter = initialParameter
        self.value = render(currentParameter)
        self.valueHistory = [value]

        self.cancellable = dispatcher.objectWillChange
            .sink(receiveValue: { [weak self] in
                guard let self = self else {
                    return
                }

                self.rerender(self.currentParameter)
            })
    }

    public convenience init(
        disablesAssertion: Bool = false,
        environment: EnvironmentValues = EnvironmentValues(),
        _ hook: @escaping (Parameter) -> Value
    ) where Parameter == Void {
        self.init(
            disablesAssertion: disablesAssertion,
            environment: environment,
            (),
            hook
        )
    }

    public func rerender(_ parameter: Parameter) {
        currentParameter = parameter
        value = render(parameter)
        valueHistory.append(value)
    }

    public func rerender() where Parameter == Void {
        rerender(())
    }

    public func unmount() {
        dispose()
    }
}
