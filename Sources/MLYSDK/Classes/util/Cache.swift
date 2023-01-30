import Foundation

class Cache<T> {
    var max: Int
    private var map: [String: CacheObject<T>] = [:]
    private var time: [TimeInterval: Queue<CacheObject<T>>] = [:]
    private var shouldClear: Bool {
        return self.map.count > self.max
    }

    init(_ max: Int = 8192) {
        self.max = max
    }

    func has(_ key: String) -> Bool {
        return self.get(key) != nil
    }

    func remove(_ key: String) -> T? {
        guard let cache = self.map.removeValue(forKey: key) else {
            return nil
        }
        cache.removed = true
        return cache.value
    }

    func removeAll() {
        self.map.removeAll(keepingCapacity: true)
        self.time.removeAll(keepingCapacity: true)
    }

    func set(_ key: String, _ value: T, _ ttl: TimeInterval) {
        let cache = CacheObject(key, value, ttl)
        self.map[key] = cache
        self.queue(ttl).append(cache)
        if self.shouldClear {
            Task {
                self.clearExpired()
            }
        }
    }

    func get(_ key: String) -> T? {
        guard let cache = self.map[key] else {
            return nil
        }
        if cache.isExpired() {
            _ = self.remove(key)
            return nil
        }
        return cache.value
    }

    private func clearExpired() {
        let now = Date.now()
        for queue in self.time.values {
            while queue.first?.isExpired(now) ?? false {
                self.removeFirst(queue)
            }
        }
    }

    private func queue(_ ttl: TimeInterval) -> Queue<CacheObject<T>> {
        if let q = time[ttl] {
            return q
        }
        let q = Queue<CacheObject<T>>()
        self.time[ttl] = q
        return q
    }

    private func removeFirst(_ queue: Queue<CacheObject<T>>) {
        guard let first = queue.removeFirst() else {
            return
        }
        self.map.removeValue(forKey: first.key)
    }
}

class CacheObject<T> {
    var value: T
    var key: String
    var ttl: TimeInterval
    var removed = false
    init(_ forKey: String, _ value: T, _ ttl: TimeInterval) {
        self.key = forKey
        self.value = value
        self.ttl = Date.now() + ttl
    }

    func isExpired(_ time: TimeInterval = Date.now()) -> Bool {
        return self.removed || self.ttl <= time
    }
}
