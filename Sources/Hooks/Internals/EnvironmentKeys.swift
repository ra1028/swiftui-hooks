import SwiftUI

internal extension EnvironmentValues {
    var hooksRulesAssertionDisabled: Bool {
        get { self[DisableHooksRulesAssertionKey.self] }
        set { self[DisableHooksRulesAssertionKey.self] = newValue }
    }
}

private struct DisableHooksRulesAssertionKey: EnvironmentKey {
    static let defaultValue = false
}
