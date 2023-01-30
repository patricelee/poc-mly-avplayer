import Foundation

class Backoff {
    var delayer: Delayer

    init(_ delayer: Delayer) {
        self.delayer = delayer
    }

    init(delayer: Delayer,
         baseInterval: TimeInterval = 0,
         multiplier: Double = 1.1,
         maxInterval: TimeInterval = 5,
         maxAttempts: Int = -1)
    {
        self.delayer = delayer
        delayer._multiplier = multiplier
        delayer._maxInterval = maxInterval
        delayer._maxAttempts = maxAttempts
    }

    func delay() async {
        let sec = self.delayer.next()
        Logger.debug("delay seconds=\(sec)")
        await Self.delay(seconds: sec)
    }

    func reset() {
        self.delayer.reset()
    }

    static func build(_ closure: () -> Delayer) -> Backoff {
        let delayer = closure()
        let r = Backoff(delayer)
        return r
    }
    
    static func delay(seconds: TimeInterval) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        } catch let err {
            Logger.error("delay error:", err)
        }
    }

}

class LinearDelayer: Delayer {
    override init(_ options: DelayerOptions? = nil) {
        var opt = options
        opt?.baseInterval = 0.5
        opt?.multiplier = 2.0
        opt?.maxInterval = 10.0
        super.init(opt)
    }

    override func _computeInterval() -> TimeInterval {
        return _baseInterval + _multiplier * Double(_attempts.count())
    }
}

class ExponentialDelayer: Delayer {
    override init(_ options: DelayerOptions? = nil) {
        var opt = options
        opt?.baseInterval = 1.0
        opt?.multiplier = 1.8
        opt?.maxInterval = 20.0
        opt?.maxAttempts = 5
        super.init(opt)
    }

    override func _computeInterval() -> TimeInterval {
        return _baseInterval + pow(_multiplier, Double(_attempts.count())) - 1
    }
}

class Delayer {
    static let DEFAULT_BASE_INTERVAL: TimeInterval = 0.0
    static let DEFAULT_MULTIPLIER: Double = 1.0
    static let DEFAULT_JITTER_FACTOR: Double = 0.2
    static let DEFAULT_MAX_INTERVAL: TimeInterval = 5.0
    static let DEFAULT_MAX_SECONDS: TimeInterval = -1
    static let DEFAULT_MAX_ATTEMPTS: Int = -1

    var _interval = 0.0
    var _seconds = Counter()
    var _attempts = Counter()
    var _baseInterval: TimeInterval
    var _multiplier: Double
    var _jitterFactor: TimeInterval
    var _maxInterval: TimeInterval
    var _maxSeconds: TimeInterval
    var _maxAttempts: Int
    var _isOverMaxAttempts: Bool {
        return self._maxAttempts >= 0 && self._attempts.hasCountedOver(self._maxAttempts)
    }

    var _isOverMaxSeconds: Bool {
        return self._maxSeconds >= 0 && self._seconds.hasCountedOver(Int(self._maxSeconds))
    }

    init(_ options: DelayerOptions?) {
        self._baseInterval = options?.baseInterval ?? Delayer.DEFAULT_BASE_INTERVAL
        self._multiplier = options?.multiplier ?? Delayer.DEFAULT_MULTIPLIER
        self._jitterFactor = options?.jitterFactor ?? Delayer.DEFAULT_JITTER_FACTOR
        self._maxInterval = options?.maxInterval ?? Delayer.DEFAULT_MAX_INTERVAL
        self._maxSeconds = options?.maxSeconds ?? Delayer.DEFAULT_MAX_SECONDS
        self._maxAttempts = options?.maxAttempts ?? Delayer.DEFAULT_MAX_ATTEMPTS
    }

    func next() -> TimeInterval {
        self._increaseSeconds()
        self._increaseAttempts()
        if self._isOverMaxSeconds { return .infinity }
        if self._isOverMaxAttempts { return .infinity }
        return self._interval
    }

    func _increaseSeconds() {
        let interval = self._makeNextInterval()
        self._interval = interval
        _ = self._seconds.plus(Int(interval))
    }

    func _makeNextInterval() -> TimeInterval {
        var interval = self._computeInterval()
        interval = self._jitterInterval(interval)
        interval = self._restrictInterval(interval)
        return interval
    }

    func _computeInterval() -> TimeInterval {
        Logger.error("_computeInterval NOT implements")
        return 0
    }

    func _jitterInterval(_ interval: TimeInterval) -> TimeInterval {
        return interval * (1 - self._jitterFactor + 2 * ByteTool.randomDouble() * self._jitterFactor)
    }

    func _restrictInterval(_ interval: TimeInterval) -> TimeInterval {
        return interval <= self._maxInterval ? interval : self._maxInterval
    }

    func _increaseAttempts() {
        _ = self._attempts.up()
    }

    func reset() {
        self._interval = 0.0
        _ = self._seconds.reset()
        _ = self._attempts.reset()
    }
}

class Counter {
    var _count: Int = 0
    var _initial: Int = 0
    var _interval: Int = 1

    func count() -> Int {
        return self._count
    }

    func reset() -> Counter {
        self._count = self._initial
        return self
    }

    func up() -> Counter {
        self._count += self._interval
        return self
    }

    func down() -> Counter {
        self._count -= self._interval
        return self
    }

    func plus(_ value: Int) -> Counter {
        self._count += value
        return self
    }

    func minus(_ value: Int) -> Counter {
        self._count -= value
        return self
    }

    func hasCountedOver(_ value: Int) -> Bool {
        return self._count > value
    }

    func hasCountedBelow(_ value: Int) -> Bool {
        return self._count < value
    }

    func hasCountedUpTo(_ value: Int) -> Bool {
        return self._count >= value
    }

    func hasCountedDownTo(_ value: Int) -> Bool {
        return self._count <= value
    }
}

struct DelayerOptions {
    var baseInterval: TimeInterval? = Delayer.DEFAULT_BASE_INTERVAL
    var multiplier: Double? = Delayer.DEFAULT_MULTIPLIER
    var jitterFactor: Double? = Delayer.DEFAULT_JITTER_FACTOR
    var maxInterval: TimeInterval? = Delayer.DEFAULT_MAX_INTERVAL
    var maxSeconds: TimeInterval? = Delayer.DEFAULT_MAX_SECONDS
    var maxAttempts: Int? = Delayer.DEFAULT_MAX_ATTEMPTS
}
