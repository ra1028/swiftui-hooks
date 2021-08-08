import Combine
import SwiftUI
import XCTest

@testable import Hooks

final class UsePublisherTests: XCTestCase {
    func testUpdateAlways() {
        let subject = PassthroughSubject<Void, Never>()
        let tester = HookTester(0) { value in
            usePublisher(.always) {
                subject.map { value }
            }
        }

        XCTAssertEqual(tester.value, .running)

        subject.send()

        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: 1)
        subject.send()

        XCTAssertEqual(tester.value.value, 1)

        tester.update(with: 2)
        subject.send()

        XCTAssertEqual(tester.value.value, 2)
    }

    func testUpdateOnce() {
        let subject = PassthroughSubject<Void, Never>()
        let tester = HookTester(0) { value in
            usePublisher(.once) {
                subject.map { value }
            }
        }

        XCTAssertEqual(tester.value, .running)

        subject.send()

        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: 1)
        subject.send()

        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: 2)
        subject.send()

        XCTAssertEqual(tester.value.value, 0)
    }

    func testUpdatePreserved() {
        let subject = PassthroughSubject<Void, Never>()
        let tester = HookTester((0, false)) { value, flag in
            usePublisher(.preserved(by: flag)) {
                subject.map { value }
            }
        }

        XCTAssertEqual(tester.value, .running)

        subject.send()

        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: (1, false))
        subject.send()

        XCTAssertEqual(tester.value.value, 0)

        tester.update(with: (2, true))
        subject.send()

        XCTAssertEqual(tester.value.value, 2)

        tester.update(with: (3, true))
        subject.send()

        XCTAssertEqual(tester.value.value, 2)
    }

    func testUpdateFailure() {
        let subject = PassthroughSubject<Int, URLError>()
        let tester = HookTester {
            usePublisher(.once) {
                subject
            }
        }

        XCTAssertEqual(tester.value, .running)

        subject.send(completion: .failure(URLError(.badURL)))

        XCTAssertEqual(tester.value.error, URLError(.badURL))
    }

    func testDispose() {
        let subject = PassthroughSubject<Int, Never>()
        let tester = HookTester {
            usePublisher(.always) {
                subject
            }
        }

        XCTAssertEqual(tester.value, .running)

        tester.dispose()
        subject.send(1)

        XCTAssertEqual(tester.value, .running)
    }
}
