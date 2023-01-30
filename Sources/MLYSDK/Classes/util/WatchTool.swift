class WatchTool {
    private var _startTime: TimeInterval
    private var _endTime: TimeInterval!

    init() {
        self._startTime = Date.now()
    }

    func hasElapsedTimeS(_ second: TimeInterval) -> Bool {
        return self.stop() >= second
    }

    func stop() -> TimeInterval {
        self._endTime = Date.now()
        return self.elapsedTimeS()
    }
    
    func elapsedTimeS() -> TimeInterval {
        return self._endTime - self._startTime
    }

    func start() {
        self._startTime = Date.now()
    }

    func reset() {
        self.start()
    }
}
