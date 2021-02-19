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

    /// Returns a result converted from the status. If the status is `pending` or `running`, it returns nil.
    public var result: Result<Success, Failure>? {
        switch self {
        case .success(let success):
            return .success(success)

        case .failure(let error):
            return .failure(error)

        case .pending, .running:
            return nil
        }
    }
}

extension AsyncStatus: Equatable where Success: Equatable, Failure: Equatable {}
extension AsyncStatus: Hashable where Success: Hashable, Failure: Hashable {}
