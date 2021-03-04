/// An immutable representation of the most recent asynchronous operation status.
@frozen
public enum AsyncStatus<Success, Failure: Error> {
    /// Represents a pending status meaning that the operation has not been started.
    case pending

    /// Represents a running status meaning that the operation has been started, but has not yet provided a result.
    case running

    /// Represents a success status meaning that the operation provided a value with success.
    case success(Success)

    /// Represents a success status meaning that the operation provided an error with failure.
    case failure(Failure)

    /// Returns a Boolean value indicating whether this instance represents a `running`.
    public var isRunning: Bool {
        guard case .running = self else {
            return false
        }
        return true
    }

    /// Returns a result converted from the status.
    /// If this instance represents a `pending` or a `running`, this returns nil.
    public var result: Result<Success, Failure>? {
        switch self {
        case .pending, .running:
            return nil

        case .success(let success):
            return .success(success)

        case .failure(let error):
            return .failure(error)
        }
    }

    /// Returns a new status, mapping any success value using the given transformation.
    /// - Parameter transform: A closure that takes the success value of this instance.
    /// - Returns: An `AsyncStatus` instance with the result of evaluating `transform` as the new success value if this instance represents a success.
    public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> AsyncStatus<NewSuccess, Failure> {
        flatMap { .success(transform($0)) }
    }

    /// Returns a new result, mapping any failure value using the given transformation.
    /// - Parameter transform: A closure that takes the failure value of the instance.
    /// - Returns: An `AsyncStatus` instance with the result of evaluating `transform` as the new failure value if this instance represents a failure.
    public func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> AsyncStatus<Success, NewFailure> {
        flatMapError { .failure(transform($0)) }
    }

    /// Returns a new result, mapping any success value using the given transformation and unwrapping the produced status.
    /// - Parameter transform: A closure that takes the success value of the instance.
    /// - Returns: An `AsyncStatus` instance, either from the closure or the previous `.success`.
    public func flatMap<NewSuccess>(_ transform: (Success) -> AsyncStatus<NewSuccess, Failure>) -> AsyncStatus<NewSuccess, Failure> {
        switch self {
        case .pending:
            return .pending

        case .running:
            return .running

        case .success(let value):
            return transform(value)

        case .failure(let error):
            return .failure(error)
        }
    }

    /// Returns a new result, mapping any failure value using the given transformation and unwrapping the produced status.
    /// - Parameter transform: A closure that takes the failure value of the instance.
    /// - Returns: An `AsyncStatus` instance, either from the closure or the previous `.failure`.
    public func flatMapError<NewFailure: Error>(_ transform: (Failure) -> AsyncStatus<Success, NewFailure>) -> AsyncStatus<Success, NewFailure> {
        switch self {
        case .pending:
            return .pending

        case .running:
            return .running

        case .success(let value):
            return .success(value)

        case .failure(let error):
            return transform(error)
        }
    }

    /// Returns the success value as a throwing expression.
    /// If this instance represents a `pending` or a `running`, this returns nil.
    ///
    /// Use this method to retrieve the value of this status if it represents a success, or to catch the value if it represents a failure.
    /// - Throws: The failure value, if the instance represents a failure.
    /// - Returns:  The success value, if the instance represents a success,If the status is `pending` or `running`, this returns nil. .
    public func get() throws -> Success? {
        switch self {
        case .pending, .running:
            return nil

        case .success(let value):
            return value

        case .failure(let error):
            throw error
        }
    }
}

extension AsyncStatus: Equatable where Success: Equatable, Failure: Equatable {}
extension AsyncStatus: Hashable where Success: Hashable, Failure: Hashable {}
