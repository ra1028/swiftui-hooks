import SwiftUI

public extension Context {
    /// A view that provides the context values through view tree.
    struct Provider<Content: View>: View {
        private let value: T
        private let content: () -> Content

        @Environment(\.self)
        private var environment

        /// Creates a `Provider` that provides the passed value.
        /// - Parameters:
        ///   - value: A value that to be provided to child views.
        ///   - content: A content view where the passed value will be provided.
        public init(value: T, @ViewBuilder content: @escaping () -> Content) {
            self.value = value
            self.content = content
        }

        /// The content and behavior of the view.
        public var body: some View {
            HookScope(content).environment(\.self, contextEnvironments)
        }
    }
}

private extension Context.Provider {
    var contextEnvironments: EnvironmentValues {
        var environment = self.environment
        environment[Context.self] = value
        return environment
    }
}
