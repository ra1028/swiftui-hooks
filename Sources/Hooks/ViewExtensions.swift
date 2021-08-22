import SwiftUI

public extension View {
    /// Sets whether to disable assertions that an internal sanity
    /// check of hooks rules.
    ///
    /// If this is disabled and a violation of hooks rules is detected,
    /// hooks will clear the unrecoverable state and attempt to continue
    /// the program.
    ///
    /// * In -O builds, assertions for hooks rules are disabled by default.
    ///
    /// - Parameter isDisabled: A Boolean value that indicates whether
    ///   the assertinos are disabled for this view.
    /// - Returns: A view that assertions disabled.
    func disableHooksRulesAssertion(_ isDisabled: Bool) -> some View {
        environment(\.hooksRulesAssertionDisabled, isDisabled)
    }
}
