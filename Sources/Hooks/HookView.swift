import SwiftUI

/// A view that wrapper around the `HookScope` to use hooks inside.
/// The view that is returned from `hookBody` will be encluded with `HookScope` and be able to use hooks.
///
///     struct ContentView: HookView {
///         var hookBody: some View {
///             let count = useState(0)
///
///             Button("\(count.wrappedValue)") {
///                 count.wrappedValue += 1
///             }
///         }
///     }
public protocol HookView: View {
    // The type of view representing the body of this view that can use hooks.
    associatedtype HookBody: View

    /// The content and behavior of the hook scoped view.
    @ViewBuilder
    var hookBody: HookBody { get }
}

public extension HookView {
    /// The content and behavior of the view.
    var body: some View {
        HookScope {
            hookBody
        }
    }
}
