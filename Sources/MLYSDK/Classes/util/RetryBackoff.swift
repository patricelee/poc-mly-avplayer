import Foundation

class RetryBackoff {

    var start: Date
    var delayer: Delayer

    init(_ delayer: Delayer) {
        self.delayer = delayer
        self.start = Date()
    }

    func next() -> Bool {
        return Date.now() - self.start.timeIntervalSince1970 >= self.delayer.next()
    }

    func reset() {
        self.start = Date()
        self.delayer.reset()
    }

}
