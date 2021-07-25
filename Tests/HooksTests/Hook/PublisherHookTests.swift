import Combine
import SwiftUI
import XCTest

@testable import Hooks

final class PublisherHookTests: XCTestCase {
    func testMakeState() {
        let hook = PublisherHook(computation: .always) {
            Just(0)
        }

        let state = hook.makeState()

        XCTAssertEqual(state.phase, .pending)
        XCTAssertNil(state.cancellable)
    }

    func testMakeValue() {
        let hook = PublisherHook(computation: .always) {
            Just(0)
        }
        let coordinator = PublisherHook<Just<Int>>
            .Coordinator(
                state: PublisherHook.State(),
                environment: EnvironmentValues(),
                updateView: {}
            )

        coordinator.state.phase = .success(100)

        let phase = hook.makeValue(coordinator: coordinator)

        XCTAssertEqual(phase, .success(100))
    }

    func testCompute() {
        typealias P = PassthroughSubject<Int, URLError>

        var viewUpdatedCount = 0
        let subject = P()
        let hook = PublisherHook<P>(computation: .always) {
            subject
        }
        let coordinator = PublisherHook<P>
            .Coordinator(
                state: PublisherHook.State(),
                environment: EnvironmentValues(),
                updateView: { viewUpdatedCount += 1 }
            )

        XCTAssertNil(coordinator.state.cancellable)
        XCTAssertEqual(coordinator.state.phase, .pending)
        XCTAssertEqual(viewUpdatedCount, 0)

        hook.compute(coordinator: coordinator)

        XCTAssertNotNil(coordinator.state.cancellable)
        XCTAssertEqual(coordinator.state.phase, .running)
        XCTAssertEqual(viewUpdatedCount, 1)

        subject.send(0)

        XCTAssertEqual(coordinator.state.phase, .success(0))
        XCTAssertEqual(viewUpdatedCount, 2)

        subject.send(1)

        XCTAssertEqual(coordinator.state.phase, .success(1))
        XCTAssertEqual(viewUpdatedCount, 3)

        subject.send(completion: .failure(URLError(.badURL)))

        XCTAssertEqual(coordinator.state.phase, .failure(URLError(.badURL)))
        XCTAssertEqual(viewUpdatedCount, 4)
    }

    func testDispose() {
        let hook = PublisherHook(computation: .always) {
            Just(0)
        }
        let state = PublisherHook<Just<Int>>.State()
        state.cancellable = AnyCancellable {}

        XCTAssertNotNil(state.cancellable)

        hook.dispose(state: state)

        XCTAssertNil(state.cancellable)
    }
}
