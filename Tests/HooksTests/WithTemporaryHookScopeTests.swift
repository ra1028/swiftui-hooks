import Hooks
import XCTest

final class WithTemporaryHookScopeTests: XCTestCase {
    struct TestHook<Value>: Hook {
        final class State {
            var value: Value

            init(value: Value) {
                self.value = value
            }
        }

        let initialValue: Value
        let compute: (Value) -> Value
        let computation = HookComputation.always

        func makeState() -> State {
            State(value: initialValue)
        }

        func makeValue(coordinator: Coordinator) -> Value {
            coordinator.state.value
        }

        func compute(coordinator: Coordinator) {
            coordinator.state.value = compute(coordinator.state.value)
        }
    }

    func useTest<Value>(
        initialValue: Value,
        compute: @escaping (Value) -> Value
    ) -> Value {
        useHook(TestHook(initialValue: initialValue, compute: compute))
    }

    func testUse() {
        let result = withTemporaryHookScope { scope -> Int in
            let result1 = scope { () -> Int in
                let value1 = useTest(initialValue: 0) { $0 + 1 }
                let value2 = useTest(initialValue: 0) { $0 + 2 }

                XCTAssertEqual(value1, 1)
                XCTAssertEqual(value2, 2)

                return 100
            }

            let result2 = scope { () -> Int in
                let value1 = useTest(initialValue: 0) { $0 + 1 }
                let value2 = useTest(initialValue: 0) { $0 + 2 }

                XCTAssertEqual(value1, 2)
                XCTAssertEqual(value2, 4)

                return 200
            }

            return result1 + result2
        }

        XCTAssertEqual(result, 300)
    }
}
