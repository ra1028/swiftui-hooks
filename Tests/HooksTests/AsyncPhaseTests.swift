import Hooks
import XCTest

final class AsyncPhaseTests: XCTestCase {
    func testIsPending() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected = [
            true,
            false,
            false,
            false,
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(phase.isPending, expected)
        }
    }

    func testIsRunning() {
        let phases: [AsyncPhase<Int, URLError>] = [
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

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(phase.isRunning, expected)
        }
    }

    func testIsSuccess() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected = [
            false,
            false,
            true,
            false,
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(phase.isSuccess, expected)
        }
    }

    func testIsFailure() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected = [
            false,
            false,
            false,
            true,
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(phase.isFailure, expected)
        }
    }

    func testValue() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [Int?] = [
            nil,
            nil,
            0,
            nil,
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(phase.value, expected)
        }
    }

    func testError() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [URLError?] = [
            nil,
            nil,
            nil,
            URLError(.badURL),
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(phase.error, expected)
        }
    }

    func testResult() {
        let phases: [AsyncPhase<Int, URLError>] = [
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

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(phase.result, expected)
        }
    }

    func testMap() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(100),
            .failure(URLError(.badURL)),
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(phase.map { _ in 100 }, expected)
        }
    }

    func testMapError() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.cancelled)),
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(
                phase.mapError { _ in URLError(.cancelled) },
                expected
            )
        }
    }

    func testFlatMap() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .failure(URLError(.callIsActive)),
            .failure(URLError(.badURL)),
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(
                phase.flatMap { _ in .failure(URLError(.callIsActive)) },
                expected
            )
        }
    }

    func testFlatMapError() {
        let phases: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .failure(URLError(.badURL)),
        ]

        let expected: [AsyncPhase<Int, URLError>] = [
            .pending,
            .running,
            .success(0),
            .success(100),
        ]

        for (phase, expected) in zip(phases, expected) {
            XCTAssertEqual(
                phase.flatMapError { _ in .success(100) },
                expected
            )
        }
    }
}
