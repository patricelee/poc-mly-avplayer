import Foundation

protocol Deque {
    associatedtype Element
    var first: Element? { get }
    var last: Element? { get }
    var size: Int { get }
    var isEmpty: Bool { get }
    
    func append(_ element: Element)
    func insert(_ element: Element)
    
    func removeFirst() -> Element?
    func removeLast() -> Element?
    
    func removeAll()
}

class DoubleDequeItem<Element> {
    var prev: DoubleDequeItem?
    var next: DoubleDequeItem?
    var value: Element?
    init(_ value: Element? = nil) {
        self.value = value
    }
}

typealias Queue = DoubleDeque
class DoubleDeque<Element>: Deque {
    var firstItem: DoubleDequeItem<Element>?
    var lastItem: DoubleDequeItem<Element>?
    var size: Int = 0
    init(_ array: [Element]? = nil) {
        self.append(array)
    }

    var isEmpty: Bool {
        self.firstItem == nil
    }

    var first: Element? {
        return self.firstItem?.value
    }

    var last: Element? {
        return self.lastItem?.value
    }
    
    func append(_ array: [Element]?) {
        array?.forEach { self.append($0) }
    }
    
    func append(_ element: Element) {
        let current = DoubleDequeItem<Element>(element)
        if let last = self.lastItem {
            last.next = current
            current.prev = last
        } else {
            self.lastItem = current
            self.firstItem = current
        }
        self.size += 1
    }
    
    func insert(_ element: Element) {
        let current = DoubleDequeItem<Element>(element)
        if let first = self.firstItem {
            first.prev = current
            current.next = first
        } else {
            self.lastItem = current
            self.firstItem = current
        }
        self.size += 1
    }
    
    func removeFirst() -> Element? {
        guard let value = self.firstItem?.value else {
            return nil
        }
        self.firstItem = self.firstItem?.next
        self.size -= 1
        return value
    }
    
    func removeLast() -> Element? {
        guard let value = self.lastItem?.value else {
            return nil
        }
        self.lastItem = self.lastItem?.prev
        self.size -= 1
        return value
    }
    
    func removeAll() {
        self.firstItem = nil
        self.lastItem = nil
        self.size = 0
    }
}
