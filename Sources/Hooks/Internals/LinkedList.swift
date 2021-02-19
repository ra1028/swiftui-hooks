internal struct LinkedList<Element>: Sequence {
    final class Node {
        fileprivate(set) var element: Element
        fileprivate(set) var next: Node?
        fileprivate(set) weak var previous: Node?

        init(_ element: Element) {
            self.element = element
        }

        @discardableResult
        func swap(element newElement: Element) -> Element {
            let oldElement = element
            element = newElement
            return oldElement
        }
    }

    private(set) var first: Node?
    private(set) weak var last: Node?

    init(first: Node? = nil, last: Node? = nil) {
        self.first = first
        self.last = last ?? first
    }

    @discardableResult
    mutating func append(_ newElement: Element) -> Node {
        let node = Node(newElement)

        if let last = last {
            node.previous = last
            last.next = node
        }
        else {
            first = node
        }

        last = node

        return node
    }

    mutating func dropSuffix(from node: Node) -> LinkedList {
        let previousLast = last

        if let previous = node.previous {
            previous.next = nil
        }
        else {
            first = nil
        }

        last = node.previous
        node.previous = nil

        return LinkedList(first: node, last: previousLast)
    }

    func reversed() -> Reversed {
        Reversed(last: last)
    }

    func makeIterator() -> Iterator {
        Iterator(first: first)
    }
}

internal extension LinkedList {
    struct Reversed: Sequence {
        let last: Node?

        func makeIterator() -> Iterator {
            Iterator(last: last)
        }

        struct Iterator: IteratorProtocol {
            private var previousNode: Node?

            init(last: Node?) {
                previousNode = last
            }

            mutating func next() -> Node? {
                let node = previousNode
                previousNode = node?.previous
                return node
            }
        }
    }

    struct Iterator: IteratorProtocol {
        private var nextNode: Node?

        init(first: Node?) {
            nextNode = first
        }

        mutating func next() -> Node? {
            let node = nextNode
            nextNode = node?.next
            return node
        }
    }
}
