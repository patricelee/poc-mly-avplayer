import Foundation

class Processor {

    static var DEFAULT_GRACEFUL_TIMEOUT: TimeInterval = 30
    static var DEFAULT_HEARTBEAT_INTERVAL: TimeInterval = 5 * 60

    var _state = ProcessorState()
    var _processStats: [ProcessStat] = []
    var _gracefulTimeout: TimeInterval
    var _heartbeatInterval: TimeInterval
    var _isEveryProcessExited: Bool {
        for stat in _processStats {
            if stat.isActive {
                return false
            }
        }
        return true
    }

    init(
        _ options:
            ProcessorOptions?) {
        self._gracefulTimeout = options?.gracefulTimeout ?? Processor.DEFAULT_GRACEFUL_TIMEOUT
        self._heartbeatInterval = options?.heartbeatInterval ?? Processor.DEFAULT_HEARTBEAT_INTERVAL
    }

    func register(_ process: SpecProcess) {
        self._processStats.append(ProcessStat(process))
    }

    func activate() async throws {
        try await _initProcesses()
        try await _startProcesses()
        try await _serveProcesses()
    }

    func deactivate() {
        self._state.toExiting()
    }

    func _initProcesses() async throws {
        for processStat in self._processStats {
            try await processStat.initProcess()
        }
        self._state.toRunning()
    }

    func _startProcesses() async throws {
        for processStat in self._processStats {
            try await processStat.startProcess(self._state)
            self._state.toExiting()
        }
    }

    func _serveProcesses() async throws {
        let watch = WatchTool()
        while true {
            if self._state.isExiting {
                _emitShutInfo()
                try await _waitProcesses()
                _emitExitInfo()
                break
            }
            if watch.hasElapsedTimeS(_heartbeatInterval) {
                _emitBeatInfo()
                watch.reset()
            }

        }
        self._state.toExited()
    }

    func _emitBeatInfo() {
        let stats = _makeProcessStatInfos()
        Logger.info("Processor heartbeats. \( stats )")
    }

    func _emitShutInfo() {
        Logger.info("Processor will graceful shutdown in \(self._gracefulTimeout) seconds.")
    }

    func _waitProcesses() async throws {
        let watch = WatchTool()
        while true {
            _emitBeatInfo()
            if self._isEveryProcessExited {
                break
            }
            if watch.hasElapsedTimeS(self._gracefulTimeout) {
                break
            }
            await Backoff.delay(seconds: 1)
        }
    }

    func _emitExitInfo() {
        let stats = _makeProcessStatInfos()
        if self._isEveryProcessExited {
            Logger.info("Processor graceful shutdown normally. \(stats)")
        } else {
            Logger.warn("Processor graceful shutdown abnormally. \(stats)")
        }
    }

    func _makeProcessStatInfos() -> [String] {
        return self._processStats.map { $0.process.debugDescription }
    }

    func throwIfError() throws {
        let errors = self._processStats.filter({ $0.error != nil }).map({ $0.error })
        guard errors.isEmpty else {
            throw ValidationError(MessageCode.EMU060)
        }
    }
}

protocol ProcessorOptions {
    var gracefulTimeout: TimeInterval? {get set}
    var heartbeatInterval: TimeInterval? {get set}
}

protocol SpecProcess {
    func Initialize() throws
    func StartDaemon(_ state: SpecProcessorState) async throws
}

protocol SpecProcessStat {
    var error: Error? {get set }
    var isActive: Bool {get set }
}

class ProcessStat: SpecProcessStat {
    var error: Error?
    var isActive: Bool = false
    var process: SpecProcess?

    init(_ process: SpecProcess? = nil) {
        self.process = process
    }

    func initProcess() async throws {
        try process?.Initialize()
        self.isActive = true
    }

    func startProcess(_ state: SpecProcessorState) async throws {
        do {
            try await self.process?.StartDaemon(state)
            self.isActive = false
            Logger.info("Process exit failed. \( self )")
        } catch let err {
            self.error = err
            Logger.error("Process exit failed. \(self)", err)
            throw err
        }

    }

}
