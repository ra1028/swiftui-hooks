import SwiftUI

/// A view that hosts the state of hooks.
/// All hooks should be called within the evaluation of this view's body.
/// The state of hooks are hosted by this view, and changes in state will cause re-evaluation the body of this view.
/// It is possible to limit the scope of re-evaluation by wrapping the views that use hooks in a `HookScope`.
///
///     struct ContentView: View {
///         var body: some View {
///             HookScope {
///                 let count = useState(0)
///
///                 Button("\(count.wrappedValue)") {
///                     count.wrappedValue += 1
///                 }
///             }
///         }
///     }
public struct HookScope<Content: View>: View {
    @StateObject
    private var dispatcher = HookDispatcher()

    @Environment(\.self)
    private var environment

    private let content: () -> Content

    /// Creates a `HookScope` that hosts the state of hooks.
    /// - Parameter content: A content view that uses the hooks.
    public init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    /// The content and behavior of the hook scoped view.
    public var body: some View {
        dispatcher.scoped(environment: environment, content)
    }
}
