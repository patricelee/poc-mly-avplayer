import Foundation

class Condition {

    var continuations: [CheckedContinuation<Void, Never>] = []
    var error: Error?

    func reset() {
        self.error = nil
        self.resume()
    }

    private func resume() {
        while !self.continuations.isEmpty {
            self.continuations.popLast()?.resume()
        }
    }

    func done() async {
        return await withCheckedContinuation({ [unowned self] continuation in
            self.continuations.append(continuation)
        }) as Void
    }

    func pass(_ error: Error? = nil) {
        self.error = error
        self.resume()
    }

    func deny(_ error: Error) {
        self.error = error
        self.resume()
    }

}
