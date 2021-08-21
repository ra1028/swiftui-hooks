public extension HookUpdateStrategy {
    static var once: Self {
        struct Unique: Equatable {}
        return self.init(dependency: Unique())
    }

    static func prevented<Value: Equatable>(by value: Value) -> Self {
        self.init(dependency: value)
    }
}

public struct HookUpdateStrategy {
    public let dependency: Dependency

    public init<D: Equatable>(dependency: D) {
        self.dependency = Dependency(dependency)
    }
}

public extension HookUpdateStrategy {
    /// A key that can be compared for value or object equality.
    struct Dependency: Equatable {
        private let value: Any
        private let equals: (Self) -> Bool

        /// Create a new key from the specified value.
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
