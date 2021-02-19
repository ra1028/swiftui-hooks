import SwiftUI

/// A type of context that to identify the context values.
public enum Context<T>: EnvironmentKey {
    ///  The default value for the context.
    public static var defaultValue: T? { nil }
}
