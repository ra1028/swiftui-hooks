import Hooks
import XCTest

final class HookUpdateStrategyTests: XCTestCase {
    func testOnce() {
        struct Unique: Equatable {}

        let key = HookUpdateStrategy.once
        let expected = HookUpdateStrategy.once
        let unexpected = HookUpdateStrategy(dependency: Unique())

        XCTAssertEqual(key.dependency, expected.dependency)
        XCTAssertNotEqual(key.dependency, unexpected.dependency)
    }

    func testPreventedByEquatable() {
        let key = HookUpdateStrategy.prevented(by: 100)
        let expected = HookUpdateStrategy.prevented(by: 100)
        let unexpected = HookUpdateStrategy.prevented(by: 1)

        XCTAssertEqual(key.dependency, expected.dependency)
        XCTAssertNotEqual(key.dependency, unexpected.dependency)
    }
}
