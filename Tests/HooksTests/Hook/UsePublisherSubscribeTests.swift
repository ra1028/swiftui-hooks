import Combine
import HooksTesting
import SwiftUI
import XCTest

@testable import Hooks

final class UsePublisherSubscribeTests: XCTestCase {
    func testUpdate() {
        let subject = PassthroughSubject<Void, URLError>()
        let tester = HookTester(0) { value in
            usePublisherSubscribe {
                subject.map { value }
            }
        }

        XCTAssertEqual(tester.value.phase, .pending)

        tester.value.subscribe()

        XCTAssertEqual(tester.value.phase, .running)

        subject.send()

        XCTAssertEqual(tester.value.phase.value, 0)

        tester.update(with: 1)
        tester.value.subscribe()
        subject.send()

        XCTAssertEqual(tester.value.phase.value, 1)

        tester.update(with: 2)
        tester.value.subscribe()
        subject.send()

        XCTAssertEqual(tester.value.phase.value, 2)
    }

    func testUpdateFailure() {
        let subject = PassthroughSubject<Void, URLError>()
        let tester = HookTester(0) { value in
            usePublisherSubscribe {
                subject.map { value }
            }
        }

        XCTAssertEqual(tester.value.phase, .pending)

        tester.value.subscribe()

        XCTAssertEqual(tester.value.phase, .running)

        subject.send(completion: .failure(URLError(.badURL)))

        XCTAssertEqual(tester.value.phase.error, URLError(.badURL))
    }

    func testDispose() {
        let subject = PassthroughSubject<Int, Never>()
        let tester = HookTester {
            usePublisherSubscribe {
                subject
            }
        }

        XCTAssertEqual(tester.value.phase, .pending)

        tester.value.subscribe()

        XCTAssertEqual(tester.value.phase, .running)

        tester.dispose()
        subject.send(1)

        XCTAssertEqual(tester.value.phase, .running)
    }
}
