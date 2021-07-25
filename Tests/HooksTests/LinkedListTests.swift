import XCTest

@testable import Hooks

final class LinkedListTests: XCTestCase {
    func testInit() {
        let first = LinkedList<Int>.Node(0)
        let last = LinkedList<Int>.Node(1)
        let list1 = LinkedList(first: first, last: last)
        let list2 = LinkedList(first: first)

        XCTAssertTrue(list1.first === first)
        XCTAssertTrue(list1.last === last)

        XCTAssertTrue(list2.first === first)
        XCTAssertTrue(list2.last === first)
    }

    func testAppend() {
        var list = LinkedList<Int>()

        list.append(0)

        XCTAssertEqual(list.first?.element, 0)
        XCTAssertEqual(list.last?.element, 0)
        XCTAssertEqual(list.map(\.element), [0])

        list.append(1)

        XCTAssertEqual(list.first?.element, 0)
        XCTAssertEqual(list.last?.element, 1)
        XCTAssertEqual(list.map(\.element), [0, 1])

        list.append(2)

        XCTAssertEqual(list.first?.element, 0)
        XCTAssertEqual(list.last?.element, 2)
        XCTAssertEqual(list.map(\.element), [0, 1, 2])
    }

    func testDropSuffix() {
        var list = LinkedList<Int>()

        list.append(0)
        list.append(1)
        let node = list.append(2)
        list.append(3)

        XCTAssertEqual(list.first?.element, 0)
        XCTAssertEqual(list.last?.element, 3)
        XCTAssertEqual(list.map(\.element), [0, 1, 2, 3])

        let suffix = list.dropSuffix(from: node)

        XCTAssertEqual(list.first?.element, 0)
        XCTAssertEqual(list.last?.element, 1)
        XCTAssertEqual(list.map(\.element), [0, 1])

        XCTAssertEqual(suffix.first?.element, 2)
        XCTAssertEqual(suffix.last?.element, 3)
        XCTAssertEqual(suffix.map(\.element), [2, 3])
    }

    func testReversed() {
        var list = LinkedList<Int>()

        list.append(0)
        list.append(1)
        list.append(2)

        XCTAssertEqual(list.reversed().map(\.element), [2, 1, 0])
    }

    func testIterator() {
        var list = LinkedList<Int>()

        list.append(0)
        list.append(1)
        list.append(2)

        var iterator = list.makeIterator()

        XCTAssertEqual(iterator.next()?.element, 0)
        XCTAssertEqual(iterator.next()?.element, 1)
        XCTAssertEqual(iterator.next()?.element, 2)
    }

    func testSwap() {
        let node = LinkedList<Int>.Node(0)
        let old = node.swap(element: 1)

        XCTAssertEqual(node.element, 1)
        XCTAssertEqual(old, 0)
    }
}
