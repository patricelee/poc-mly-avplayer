import Foundation

class DriverDaemon {
    static let DEFAULT_PROCESSOR_OPTIONS = DefaultProcessorOptions()
    var _processor: Processor?
    func activate() async throws {
        self._processor = Processor(DriverDaemon.DEFAULT_PROCESSOR_OPTIONS)
        self._processor?.register(createProcess())
        try await self._processor?.activate()
        try self._processor?.throwIfError()
    }

    func deactivate() {
        self._processor?.deactivate()
        self._processor = nil
    }

    func createProcess() -> SpecProcess {
        return SystemProcess()
    }
    
    class DefaultProcessorOptions: ProcessorOptions {
        var gracefulTimeout: TimeInterval? = 10
        var heartbeatInterval: TimeInterval? = 5 * 60
    }
}

class SystemProcess: SpecProcess {
    var booter: SystemBooter?
    func Initialize() {
        self.booter = SystemBooterHolder.instance
    }
    func StartDaemon(_ state: SpecProcessorState) async throws {
        await self.booter?.activate()
        while state.isRunning {
            await TaskTool.delay(seconds: 1)
        }
        await self.booter?.deactivate()
    }
}

class DriverSupervisor {
    var _isActive: Bool = false
    var _backoff: Backoff {
        var options = DelayerOptions()
        options.maxInterval = 60
        options.maxAttempts = -1
        let delayer = ExponentialDelayer(options)
        return Backoff(delayer)
    }
    lazy var _daemon: DriverDaemon = buildDaemon()

    func buildDaemon() -> DriverDaemon {
        return DriverDaemon()
    }

    func activate() async {
        self._isActive = true
        while self._isActive {
            do {
                try await self._daemon.activate()
                self._backoff.reset()
            } catch let err {
                Logger.error(err)
                await self._backoff.delay()
            }
        }
    }

    func deactivate() {
        self._daemon.deactivate()
        self._isActive = false
    }
}
