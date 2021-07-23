import Hooks
import XCTest

final class HookComputationTests: XCTestCase {
    func testPreservedByEquatable() {
        let comp = HookComputation.preserved(by: 100)
        let expected = HookComputation.preservedBy(HookComputation.Key(100))
        let unexpected = HookComputation.preservedBy(HookComputation.Key(0))

        XCTAssertEqual(comp, expected)
        XCTAssertNotEqual(comp, unexpected)
    }

    func testReCompute() {
        final class Object {}

        let object = Object()
        let compPairs: [(old: HookComputation, new: HookComputation)] = [
            (.always, .always),
            (.always, .once),
            (.always, .preserved(by: 0)),
            (.once, .always),
            (.once, .once),
            (.once, .preserved(by: 0)),
            (.preserved(by: 0), .once),
            (.preserved(by: 0), .always),
            (.preserved(by: 0), .preserved(by: 1)),
            (.preserved(by: 1), .preserved(by: 1)),
            (.preserved(by: object), .preserved(by: Object())),
            (.preserved(by: object), .preserved(by: object)),
        ]

        let expected: [Bool] = [
            true,
            true,
            true,
            true,
            false,
            true,
            true,
            true,
            true,
            false,
            true,
            false,
        ]

        for (compPair, expected) in zip(compPairs, expected) {
            XCTAssertEqual(
                compPair.old.shouldRecompute(for: compPair.new),
                expected
            )
        }
    }

    func testValueKey() {
        let key = HookComputation.Key(100)
        let expected = HookComputation.Key(100)
        let unexpected = HookComputation.Key(-100)

        XCTAssertEqual(key, expected)
        XCTAssertNotEqual(key, unexpected)
    }

    func testObjectKey() {
        final class Object {}

        let object = Object()
        let key = HookComputation.Key(object)
        let expected = HookComputation.Key(object)
        let unexpected = HookComputation.Key(Object())

        XCTAssertEqual(key, expected)
        XCTAssertNotEqual(key, unexpected)
    }
}
