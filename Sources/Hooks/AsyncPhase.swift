/// An immutable representation of the most recent asynchronous operation phase.
@frozen
public enum AsyncPhase<Success, Failure: Error> {
    /// Represents a pending phase meaning that the operation has not been started.
    case pending

    /// Represents a running phase meaning that the operation has been started, but has not yet provided a result.
    case running

    /// Represents a success phase meaning that the operation provided a value with success.
    case success(Success)

    /// Represents a failure phase meaning that the operation provided an error with failure.
    case failure(Failure)

    /// Returns a Boolean value indicating whether this instance represents a `pending`.
    public var isPending: Bool {
        guard case .pending = self else {
            return false
        }
        return true
    }

    /// Returns a Boolean value indicating whether this instance represents a `running`.
    public var isRunning: Bool {
        guard case .running = self else {
            return false
        }
        return true
    }

    /// Returns a Boolean value indicating whether this instance represents a `success`.
    public var isSuccess: Bool {
        guard case .success = self else {
            return false
        }
        return true
    }

    /// Returns a Boolean value indicating whether this instance represents a `failure`.
    public var isFailure: Bool {
        guard case .failure = self else {
            return false
        }
        return true
    }

    /// Returns a success value if this instance is `success`, otherwise returns `nil`.
    public var value: Success? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }

    /// Returns an error if this instance is `failure`, otherwise returns `nil`.
    public var error: Failure? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }

    /// Returns a result converted from the phase.
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

    /// Returns a new phase, mapping any success value using the given transformation.
    /// - Parameter transform: A closure that takes the success value of this instance.
    /// - Returns: An `AsyncPhase` instance with the result of evaluating `transform` as the new success value if this instance represents a success.
    public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> AsyncPhase<NewSuccess, Failure> {
        flatMap { .success(transform($0)) }
    }

    /// Returns a new result, mapping any failure value using the given transformation.
    /// - Parameter transform: A closure that takes the failure value of the instance.
    /// - Returns: An `AsyncPhase` instance with the result of evaluating `transform` as the new failure value if this instance represents a failure.
    public func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> AsyncPhase<Success, NewFailure> {
        flatMapError { .failure(transform($0)) }
    }

    /// Returns a new result, mapping any success value using the given transformation and unwrapping the produced phase.
    /// - Parameter transform: A closure that takes the success value of the instance.
    /// - Returns: An `AsyncPhase` instance, either from the closure or the previous `.success`.
    public func flatMap<NewSuccess>(_ transform: (Success) -> AsyncPhase<NewSuccess, Failure>) -> AsyncPhase<NewSuccess, Failure> {
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

    /// Returns a new result, mapping any failure value using the given transformation and unwrapping the produced phase.
    /// - Parameter transform: A closure that takes the failure value of the instance.
    /// - Returns: An `AsyncPhase` instance, either from the closure or the previous `.failure`.
    public func flatMapError<NewFailure: Error>(_ transform: (Failure) -> AsyncPhase<Success, NewFailure>) -> AsyncPhase<Success, NewFailure> {
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
}

extension AsyncPhase: Equatable where Success: Equatable, Failure: Equatable {}
extension AsyncPhase: Hashable where Success: Hashable, Failure: Hashable {}
