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
        guard case let .success(value) = self else {
            return nil
        }
        return value
    }

    /// Returns an error if this instance is `failure`, otherwise returns `nil`.
    public var error: Failure? {
        guard case let .failure(error) = self else {
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

        case let .success(success):
            return .success(success)

        case let .failure(error):
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

        case let .success(value):
            return transform(value)

        case let .failure(error):
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

        case let .success(value):
            return .success(value)

        case let .failure(error):
            return transform(error)
        }
    }

    /// Executes the given closure when the phase is `.success`.
    /// - Parameter body: A closure that takes the success value.
    public func ifSuccess(_ body: (Success) -> Void) {
        if case let .success(value) = self {
            body(value)
        }
    }

    /// Executes the given closure when the phase is `.failure`.
    /// - Parameter body: A closure that takes the failure value.
    public func ifFailure(_ body: (Failure) -> Void) {
        if case let .failure(error) = self {
            body(error)
        }
    }

    /// Returns the success value if the phase is `.success`, otherwise throws the failure error.
    /// - Throws: The failure error if the phase is `.failure`, or a `PhaseError.incomplete` if the phase is `.pending` or `.running`.
    /// - Returns: The success value.
    public func unwrap() throws -> Success {
        switch self {
        case let .success(value):
            return value

        case let .failure(error):
            throw error

        case .pending, .running:
            throw PhaseError.incomplete
        }
    }
}

/// Errors that can occur when working with `AsyncPhase`.
public enum PhaseError: Error, Equatable {
    /// The phase is incomplete (either `.pending` or `.running`).
    case incomplete
}

public extension AsyncPhase {
    /// Creates a new phase from a `Result`.
    /// - Parameter result: A result to convert.
    init(from result: Result<Success, Failure>) {
        switch result {
        case let .success(value):
            self = .success(value)
        case let .failure(error):
            self = .failure(error)
        }
    }
}

extension AsyncPhase: Equatable where Success: Equatable, Failure: Equatable {}
extension AsyncPhase: Hashable where Success: Hashable, Failure: Hashable {}
extension AsyncPhase: Sendable where Success: Sendable, Failure: Sendable {}
