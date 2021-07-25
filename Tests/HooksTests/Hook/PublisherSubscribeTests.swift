import Combine
import SwiftUI
import XCTest

@testable import Hooks

final class PublisherSubscribeHookTests: XCTestCase {
    func testMakeState() {
        let hook = PublisherSubscribeHook {
            Just(0)
        }

        let state = hook.makeState()

        XCTAssertEqual(state.phase, .pending)
        XCTAssertFalse(state.isDisposed)
        XCTAssertNil(state.cancellable)
    }

    func testMakeValue() {
        typealias P = PassthroughSubject<Int, URLError>

        var viewUpdatedCount = 0
        let subject = P()
        let hook = PublisherSubscribeHook<P> {
            subject
        }
        let coordinator = PublisherSubscribeHook<P>
            .Coordinator(
                state: PublisherSubscribeHook.State(),
                environment: EnvironmentValues(),
                updateView: { viewUpdatedCount += 1 }
            )

        XCTAssertNil(coordinator.state.cancellable)
        XCTAssertEqual(coordinator.state.phase, .pending)
        XCTAssertEqual(viewUpdatedCount, 0)

        let (_, subscribe) = hook.makeValue(coordinator: coordinator)

        subject.send(0)

        XCTAssertNil(coordinator.state.cancellable)
        XCTAssertEqual(coordinator.state.phase, .pending)
        XCTAssertEqual(viewUpdatedCount, 0)

        subscribe()

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

    func testMakeValueDisposed() {
        typealias P = PassthroughSubject<Int, URLError>

        var viewUpdatedCount = 0
        let subject = P()
        let hook = PublisherSubscribeHook<P> {
            subject
        }
        let coordinator = PublisherSubscribeHook<P>
            .Coordinator(
                state: PublisherSubscribeHook.State(),
                environment: EnvironmentValues(),
                updateView: { viewUpdatedCount += 1 }
            )

        coordinator.state.isDisposed = true

        let (_, subscribe) = hook.makeValue(coordinator: coordinator)

        subscribe()

        XCTAssertNil(coordinator.state.cancellable)
        XCTAssertEqual(coordinator.state.phase, .pending)
        XCTAssertEqual(viewUpdatedCount, 0)
    }

    func testDispose() {
        let hook = PublisherSubscribeHook {
            Just(0)
        }
        let state = PublisherSubscribeHook<Just<Int>>.State()
        state.cancellable = AnyCancellable {}

        XCTAssertFalse(state.isDisposed)
        XCTAssertNotNil(state.cancellable)

        hook.dispose(state: state)

        XCTAssertTrue(state.isDisposed)
        XCTAssertNil(state.cancellable)
    }
}
