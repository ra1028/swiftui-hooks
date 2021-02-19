/// Represents a computation strategy that when to re-compute the value of the hook.
public enum HookComputation: Equatable {
    /// Indicates that the computation will performed always the view is evaluated.
    case always

    /// Indicates that the computation will not be performed after once it is done.
    case once

    /// Indicates that the computation will not be performed until the specified key is changed after once it is done.
    case preservedBy(Key)

    /// Indicates that the computation will not be performed until the specified value is changed after once it is done.
    public static func preserved<Value: Equatable>(by value: Value) -> HookComputation {
        .preservedBy(Key(value))
    }

    /// Indicates that the computation will not be performed until the specified object is changed after once it is done.
    public static func preserved<Object: AnyObject>(by object: Object) -> HookComputation {
        .preservedBy(Key(object))
    }

    /// Indicates whether a re-computation should be performed.
    /// - Parameter next: A next computation strategy.
    /// - Returns: A Boolean value indicating whether a re-computation should be performed.
    public func shouldRecompute(for next: Self) -> Bool {
        switch (self, next) {
        case (.once, .once):
            return false

        case (.preservedBy(let key), .preservedBy(let newKey)):
            return key != newKey

        case (_, .always),
            (_, .once),
            (_, .preservedBy):
            return true
        }
    }
}

public extension HookComputation {
    /// A key that can be compared for value or object equality.
    struct Key: Equatable {
        private let value: Any
        private let isEqual: (Self) -> Bool

        /// Create a new key from the specified object.
        /// - Parameter object: An actual object that will be compared.
        public init<Object: AnyObject>(_ object: Object) {
            self.init(ObjectIdentifier(object))
        }

        /// Create a new key from the specified value.
        /// - Parameter value: An actual value that will be compared.
        public init<T: Equatable>(_ value: T) {
            if let key = value as? Self {
                self = key
                return
            }

            self.value = value
            self.isEqual = { other in
                value == other.value as? T
            }
        }

        /// Returns a Boolean value indicating whether two values are equal.
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        /// - Returns: A Boolean value indicating whether two values are equal.
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.isEqual(rhs)
        }
    }
}
