class AbstractFileDownloader: AbstractDownloader {
    var _proxy: AbstractDownloaderProxy?
    var _proxyAgent: AbstractDownloaderAgent!
    var _proxyClasses: Queue<AbstractDownloaderProxy.Type>?
    var _allowRetry: Bool = false
    var _backoff = Backoff(
        delayer: ExponentialDelayer(),
        multiplier: 1.1,
        maxInterval: 5,
        maxAttempts: -1
    )
    var _shouldRetry: Bool {
        return !self._isAborted && (!self._isQueueEmpty || self._allowRetry)
    }

    var _isQueueEmpty: Bool {
        return self._proxyClasses!.isEmpty
    }

    var _isComplete: Bool {
        return self._task?.isCompleted ?? false
    }

    var _shouldFetch: Bool {
        return !self._isAborted && !self._isComplete
    }

    func _initialize() {}

    override func _fetch() async throws {
        while self._shouldFetch {
            await self._ensureQueue()
            await self._electProxy()
            try await self._proxyFetch()
            self._exposeTask()
        }
    }

    override func _abort() async {
        await self._proxy?.abort()
    }

    func _ensureQueue() async {
        if self._proxyClasses == nil || self._proxyClasses?.first == nil {
            self._proxyClasses = .init(self._proxyAgent.makeProxyClasses()) 
        }
    }

    func _electProxy() async {
        if self._proxy == nil {
            let proxyClass = self._proxyClasses?.removeFirst()
            self._proxy = proxyClass?.init(self._resource)
        }
    }

    func _proxyFetch() async throws {
        self._backoff.reset()
        do {
            try await self._proxy!.fetch()
        } catch {
            Logger.error("File downloader fetch failed. \(_resource.uri)", error)
            await self._proxy?.abort()
            self._proxy = nil
            if !self._shouldRetry {
                throw error
            }
            await self._backoff.delay()
        }
    }
    
    func _exposeTask() {
        self._task = self._proxy?._task
    }
}
