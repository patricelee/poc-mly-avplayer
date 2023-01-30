class FileSeeker {
    static let resourceCache = ResourceCache()

    var _requester: AbstractFileRequester!
    var _resourceCache: ResourceCache!

    init() {
        self._initialize()
    }

    func activate() async {
        await self._activate()
    }

    func deactivate() async {
        await self._deactivate()
    }

    func fetch(_ resource: Resource) async -> Resource? {
        return await self._fetch(resource, true)
    }

    func prefetch(_ resource: Resource) async -> Resource? {
        return await self._fetch(resource, false)
    }

    func _fetch(_ resource: Resource, _ isBlocking: Bool) async -> Resource? {
        if let res = _fetchCache(resource) {
            Logger.debug("cache got count=\(resource.size)/\(resource.total ?? -1) \(resource.uri)")
            return res
        }
        return await self._request(resource, isBlocking)
    }

    func _request(_ resource: Resource, _ isBlocking: Bool) async -> Resource? {
        guard let request = await self._requester.fetch(resource) else {
            return nil
        }
        self._storeCache(request.resource)
        if isBlocking {
            await request.done()
            self._storeCache(request.resource)
            await self._requester.clear(request.resource)
        } else {
            Task {
                await request.done()
                self._storeCache(request.resource)
                await self._requester.clear(request.resource)
            }
        }
        return request.resource
    }

    func abort(_ resource: Resource) async {
        await self._requester.abort(resource)
    }

    func _hasCached(_ resource: Resource) -> Bool {
        return self._resourceCache.has(resource.id)
    }

    func _fetchCache(_ resource: Resource) -> Resource? {
        return self._resourceCache.get(resource.id)
    }

    func _storeCache(_ resource: Resource) {
        let cacheTTL = ResourceTTLSuggester.give(resource)
        self._resourceCache.set(resource.id, resource, cacheTTL)
    }

    func _hasFetched(_ resource: Resource) -> Bool {
        return resource.isComplete
    }

    func _initialize() {
        self._requester = FileRequester()
        self._resourceCache = Self.resourceCache
    }

    func _activate() async {
        await self._requester.activate()
    }

    func _deactivate() async {
        await self._requester.deactivate()
    }
}

class FileRequester: AbstractFileRequester {
    override func _activate() async {
        await DownloadTaskManagerHolder.instance.activate()
        await self._buildTasks()
    }

    override func _deactivate() async {
        await DownloadTaskManagerHolder.instance.deactivate()
        self._requestPool.removeAll()
    }

    override func _buildTasks() async {
        await _buildClearRequestTask()
    }

    override func _buildObtainResourceTask(_ resource: Resource) async -> SpecTask? {
        let options = ObtainResourceDutyOptions()
        options.content = resource
        let duty = ObtainResourceDuty(options)
        do {
            try await duty._downloader.fetch()
        } catch {
            Logger.error("FileRequester._buildObtainResourceTask error", error)
            await duty.onFail()
        }
        if duty._downloader._task == nil {
            Logger.error("FileRequester._buildObtainResourceTask task nil")
        }
        return duty._downloader._task
    }
}

class ObtainResourceDuty: AbstractObtainResourceDuty {
    override init(
        _ _options: ObtainResourceDutyOptions)
    {
        super.init(_options)
        self._initialize()
    }

    override func _initialize() {
        self._downloader = FileDownloader(_options.content!)
    }
}

enum FileSeekerHolder {
    static var _instance: FileSeeker?

    static var instance: FileSeeker? {
        get {
            return Self._instance
        }
        set {
            Self._instance = newValue
        }
    }

    static func fetch(_ resource: Resource) async -> Resource? {
        return await Self._instance?.fetch(resource)
    }

    static func prefetch(_ resource: Resource) async -> Resource? {
        return await Self._instance?.prefetch(resource)
    }

    static func abort(_ resource: Resource) async {
        await Self._instance?.abort(resource)
    }
}
