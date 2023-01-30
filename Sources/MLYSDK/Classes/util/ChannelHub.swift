class ChannelHub {
    var data: [String: Any] = [:]
    var conditions: [String: Condition] = [:]
    
    func close() async {
        self.conditions.values.forEach { v in
            v.deny(CancellationError())
        }
        conditions.removeAll(keepingCapacity: true)
    }

    func connect(_ channel: String) {
        self.conditions[channel] = .init()
    }

    func deliver(_ key: String, _ value: Any) {
        self.data[key] = value
        self.conditions[key]?.pass()
    }

    func extract(_ key: String) async -> Any? {
        await self.conditions[key]?.done()
        return self.data[key]
    }
}
