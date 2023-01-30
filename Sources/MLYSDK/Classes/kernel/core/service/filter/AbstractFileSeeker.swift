class ResourceCache {
    var _cache: Cache<Resource> = .init(KernelSettings.instance.download.maxCacheItems)

    func has(_ resource: Resource) -> Bool {
        return self.has(resource.id)
    }

    func has(_ id: String) -> Bool {
        return self._cache.has(id)
    }

    func set(_ id: String, _ resource: Resource, _ ttl: TimeInterval) {
        self._cache.set(id, resource, ttl)
    }

    func get(_ id: String) -> Resource? {
        return self._cache.get(id)
    }
}

class AbstractFileRequester {
    static let ABORTED_REQUEST_EXPIRY_TIME: TimeInterval = 10 * 60

    lazy var _requestPool: [String: Request] = [:]
    lazy var _taskManager: TaskManager = .init()

    func activate() async {
        await self._activate()
    }

    func _activate() async {}

    func deactivate() async {
        await self._deactivate()
    }

    func _deactivate() async {}

    func _buildTasks() async {}

    func fetch(_ resource: Resource) async -> Request? {
        var request: Request?
        if self._hasRequested(resource) {
            request = self._fetchRequest(resource)
        } else {
            request = await self._buildRequest(resource)
        }
        if request?.isAborted ?? false, let res = request?.resource {
            request = await self._buildRequest(res)
        }
        return request
    }

    func abort(_ resource: Resource) async {
        if let request = self._fetchRequest(resource) {
            await self._abortRequest(request)
            self._clearRequest(resource)
        }
    }

    func clear(_ resource: Resource) async {
        self._clearRequest(resource)
    }

    func _buildRequest(_ resource: Resource) async -> Request? {
        let task = await self._buildObtainResourceTask(resource)
        guard let task = task else {
            Logger.error("_buildRequest nil task")
            return nil
        }
        let request = Request(task, resource)
        self._storeRequest(resource, request)
        return request
    }

    func _buildObtainResourceTask(_ resource: Resource) async -> SpecTask? {
        Logger.error("_buildObtainResourceTask didnot implemented")
        return nil
    }

    func _hasRequested(_ resource: Resource) -> Bool {
        return self._requestPool[resource.id] != nil
    }

    func _fetchRequest(_ resource: Resource) -> Request? {
        return self._requestPool[resource.id]
    }

    func _storeRequest(_ resource: Resource, _ request: Request) {
        self._requestPool[resource.id] = request
    }

    func _clearRequest(_ resource: Resource) {
        self._requestPool.removeValue(forKey: resource.id)
    }

    func _abortRequest(_ request: Request) async {
        await request.abort(FileRequesterError.REQUEST_ABORTED)
    }

    func _buildClearRequestTask() async {
        await self._taskManager.createCyclicTask(
            TaskState(
                name: FileRequesterTaskName.CLEAR_REQUEST,
                sleepFirst: true,
                sleepSeconds: 20,
                sleepJitter: 0,
                maxErrorRetry: -1,
                maxTotalRetry: -1
            ) {
                await self._execClearRequestTaskCallee()
            }
        )
    }

    func _execClearRequestTaskCallee() async {
        let requests = self._requestPool.values
        for request in requests {
            if request.isAborted &&
                request.resource.mtime.hasElapsedTimeS(AbstractFileRequester.ABORTED_REQUEST_EXPIRY_TIME)
            {
                self._clearRequest(request.resource)
            }
        }
    }
}

enum FileRequesterTaskName {
    static var CLEAR_REQUEST = "file requester: clear request"
    static var OBTAIN_RESOURCE = "file requester: obtain resource"
}

enum FileRequesterError {
    static let REQUEST_ABORTED = InternalError(MessageCode.ESC000)
}

class AbstractObtainResourceDuty: CommonDuty<Resource> {
    typealias T = Resource

    var _downloader: AbstractFileDownloader!

    func _initialize() {}

    func callee() async throws {
        try await self._downloader.fetch()
    }

    func onFail() async {
        await self._downloader.abort()
    }

    func onCancel() async {
        await self._downloader.abort()
    }
}

typealias ObtainResourceDutyOptions = CommonTaskOptions<Resource>

class CommonTaskOptions<T> {
    var content: T?
}

class CommonDuty<T> {
    var _options: CommonTaskOptions<T>
    init(_ _options: CommonTaskOptions<T>) {
        self._options = _options
    }
}
