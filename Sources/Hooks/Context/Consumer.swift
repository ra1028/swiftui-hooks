import SwiftUI

public extension Context {
    /// A view that consumes the context values that provided by `Provider` through view tree.
    /// If the value is not provided by the `Provider` from upstream of the view tree, the view's evaluation will be asserted.
    struct Consumer<Content: View>: View {
        private let content: (T) -> Content

        @Environment(\.self)
        private var environment

        /// Creates a `Consumer` that consumes the provided value.
        /// - Parameter content: A content view that be able to use the provided value.
        public init(@ViewBuilder content: @escaping (T) -> Content) {
            self.content = content
        }

        /// The content and behavior of the view.
        public var body: some View {
            if let value = environment[Context.self] {
                content(value)
            }
            else {
                assertMissingContext()
            }
        }
    }
}

private extension Context.Consumer {
    func assertMissingContext() -> some View {
        assertionFailure(
            """
            No context value of type \(Context.self) found.
            A \(Context.self).Provider.init(value:content:) is missing as an ancestor of the consumer.

            - SeeAlso: https://reactjs.org/docs/context.html#contextprovider
            """
        )
        return EmptyView()
    }
}
