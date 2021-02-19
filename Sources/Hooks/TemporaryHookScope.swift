import SwiftUI

/// Evaluates a closure passing a function to launch temporary hook scopes that to preserve the hook state.
/// Use this function to test your custom hooks.
///
///     withTemporaryHookScope { scope in
///         scope {
///             let count = useState(0)
///             count.wrappedValue = 1
///         }
///
///         scope {
///             let count = useState(0)
///             XCTAssertEqual(count.wrappedValue, 1)  // The previous state is preserved.
///         }
///     }
///
/// - Parameters:
///   - disablesAssertion: Indicates whether to disable assertions of hooks.
///   - environment: An environment values that will be passed to hooks.
///   - body: A closure that to be executed with passed function to launch temporary hook scopes.
/// - Throws: An error raised by the passed closure.
/// - Returns: A result value returned from the passed closure.
@discardableResult
public func withTemporaryHookScope<Result>(
    disablesAssertion: Bool = false,
    environment: EnvironmentValues = EnvironmentValues(),
    _ body: (TemporaryHookScope) throws -> Result
) rethrows -> Result {
    assertMainThread()

    let scope = TemporaryHookScope(
        dispatcher: HookDispatcher(),
        disablesAssertion: disablesAssertion,
        environment: environment
    )

    return try body(scope)
}

/// Represents a function that to launch a scope of hooks.
public struct TemporaryHookScope {
    private let dispatcher: HookDispatcher
    private let disablesAssertion: Bool
    private let environment: EnvironmentValues

    internal init(
        dispatcher: HookDispatcher,
        disablesAssertion: Bool,
        environment: EnvironmentValues
    ) {
        self.dispatcher = dispatcher
        self.disablesAssertion = disablesAssertion
        self.environment = environment
    }

    /// Evaluates the passed closure within the scope of hooks.
    /// Calling this function is equivalent to the body of `HookScope` being evaluated for hooks.
    /// - Parameter body: A closure that to be called inside the hook scope.
    /// - Throws: An error raised by the passed closure.
    /// - Returns: A result value returned from the passed closure.
    @discardableResult
    public func callAsFunction<Result>(_ body: () throws -> Result) rethrows -> Result {
        assertMainThread()

        return try dispatcher.scoped(
            disablesAssertion: disablesAssertion,
            environment: environment,
            body
        )
    }
}
