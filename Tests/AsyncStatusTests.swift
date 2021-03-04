import Hooks
import XCTest

final class AsyncStatusTests: XCTestCase {
    func testIsRunning() {
        let statuses: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected = [
            false,
            true,
            false,
            false,
        ]

        for (status, expected) in zip(statuses, expected) {
            XCTAssertEqual(status.isRunning, expected)
        }
    }

    func testResult() {
        let statuses: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [Result<Int, URLError>?] = [
            nil,
            nil,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        for (status, expected) in zip(statuses, expected) {
            XCTAssertEqual(status.result, expected)
        }
    }

    func testMap() {
        let statuses: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(100),
            .failure(URLError(.badURL)),
        ]

        for (status, expected) in zip(statuses, expected) {
            XCTAssertEqual(status.map { _ in 100 }, expected)
        }
    }

    func testMapError() {
        let statuses: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.cancelled)),
        ]

        for (status, expected) in zip(statuses, expected) {
            XCTAssertEqual(
                status.mapError { _ in URLError(.cancelled) },
                expected
            )
        }
    }

    func testFlatMap() {
        let statuses: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .failure(URLError(.callIsActive)),
            .failure(URLError(.badURL)),
        ]

        for (status, expected) in zip(statuses, expected) {
            XCTAssertEqual(
                status.flatMap { _ in .failure(URLError(.callIsActive)) },
                expected
            )
        }
    }

    func testFlatMapError() {
        let statuses: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .success(100),
        ]

        for (status, expected) in zip(statuses, expected) {
            XCTAssertEqual(
                status.flatMapError { _ in .success(100) },
                expected
            )
        }
    }

    func testGet() throws {
        let statuses: [AsyncStatus<Int, URLError>] = [
            .pending,
            .running,
            .success(100),
        ]

        let expected: [Int?] = [
            nil,
            nil,
            100,
            nil
        ]

        for (status, expected) in zip(statuses, expected) {
            XCTAssertEqual(
                try status.get(),
                expected
            )
        }

        do {
            let error = URLError(.badServerResponse)
            _ = try AsyncStatus<Int, URLError>.failure(error).get()
        }
        catch {
            let error = error as? URLError
            XCTAssertEqual(error, URLError(.badServerResponse))
        }
    }
}
