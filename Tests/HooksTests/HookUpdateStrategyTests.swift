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

    func testPreservedByEquatable() {
        let key = HookUpdateStrategy.preserved(by: 100)
        let expected = HookUpdateStrategy.preserved(by: 100)
        let unexpected = HookUpdateStrategy.preserved(by: 1)

        XCTAssertEqual(key.dependency, expected.dependency)
        XCTAssertNotEqual(key.dependency, unexpected.dependency)
    }
}
