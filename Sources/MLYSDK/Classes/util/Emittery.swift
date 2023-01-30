class Emittery {
    var ev = EventTool()
    var count: [String: Int] = [:]
    
    func clearListeners() {
        self.count.removeAll(keepingCapacity: true)
        self.ev.unregisterAll()
    }

    func on(_ event: String, _ handler: @escaping (Any) -> ()) {
        self.count[event] = (self.count[event] ?? 0) + 1
        self.ev.on(event, handler)
    }
    
    func emit(_ event: String, _ data: Any) {
        self.ev.emit(event, data)
    }

    func listenerCount(_ event: String) -> Int {
        return self.count[event] ?? 0
    }
}
