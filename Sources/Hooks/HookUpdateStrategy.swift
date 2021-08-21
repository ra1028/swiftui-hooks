public extension HookUpdateStrategy {
    /// A strategy that a hook will update its state just once.
    static var once: Self {
        struct Unique: Equatable {}
        return self.init(dependency: Unique())
    }

    /// Returns a strategy that a hook will update its state when the given value is changed.
    /// - Parameter value: The value to check against when determining whether to update a state of hook.
    /// - Returns: A strategy that a hook will update its state when the given value is changed.
    static func preserved<Value: Equatable>(by value: Value) -> Self {
        self.init(dependency: value)
    }
}

/// Represents a strategy that determines when to update the state of hooks.
public struct HookUpdateStrategy {
    /// A dependency value for updates. Hooks will attempt to update a state of hook when this value changes.
    public let dependency: Dependency

    /// Creates a new strategy with given dependency value.
    /// - Parameter dependency: A dependency value that to determine if a hook should update its state.
    public init<D: Equatable>(dependency: D) {
        self.dependency = Dependency(dependency)
    }
}

public extension HookUpdateStrategy {
    /// A type erased dependency value that to determine if a hook should update its state.
    struct Dependency: Equatable {
        private let value: Any
        private let equals: (Self) -> Bool

        /// Create a new dependency from the given equatable value.
        /// - Parameter value: An actual value that will be compared.
        public init<T: Equatable>(_ value: T) {
            if let key = value as? Self {
                self = key
                return
            }

            self.value = value
            self.equals = { other in
                value == other.value as? T
            }
        }

        /// Returns a Boolean value indicating whether two values are equal.
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        /// - Returns: A Boolean value indicating whether two values are equal.
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.equals(rhs)
        }
    }
}
