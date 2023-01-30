class BaseDownloaderProxyName {
    static var HTTP = "http"
}

class AbstractDownloaderAgent {
    var _proxyNames: [String] {
        return []
    }

    var _proxyClasses: [String: AbstractDownloaderProxy.Type] {
        return [:]
    }

    func makeProxyClasses() -> [AbstractDownloaderProxy.Type] {
        let proxyNames = self._proxyNames
        var proxyClasses: [AbstractDownloaderProxy.Type] = []
        for proxyName in proxyNames {
            if let proxyClass = _proxyClasses[proxyName] {
                proxyClasses.append(proxyClass)
            }
        }
        return proxyClasses
    }
}

class AbstractDownloaderProxy: AbstractDownloader {
    override func fetch() async throws {
        try await self._setup()
        try await super.fetch()
    }

    func _setup() async throws {}
}

class AbortController {
    var task: SpecTask?
    func abort() {
        self.task?.abort()
    }
}

typealias Payload = DownloadTask

enum HTTPHeader {
    static let RANGE = "range"
    static let CONTENT_TYPE = "content-type"
    static let CONTENT_LENGTH = "content-length"
}

class AbstractHttpDownloaderProxy: AbstractDownloaderProxy {
    var _requestURI: String!
    lazy var _aborter: AbortController = .init()
    lazy var _watch: WatchTool = .init()
    var _responseStatus: Int? {
        return self._task?.state
    }

    required init(
        _ _resource: Resource)
    {
        super.init(_resource)
        self._requestURI = _resource.uri
    }

    override func _fetch() async throws {
        await self._buildAborter()
        try await self._buildPayload()
        switch self._responseStatus {
        case 200:
            await self._handleEntireContent()
        case 206:
            await self._handlePartialContent()
        default:
            try await self._handleInvalidContent()
        }
    }

    func _buildAborter() async {
        self._aborter = AbortController()
    }

    func _buildPayload() async throws {
        guard let url = URL(string: self._requestURI) else {
            return
        }
        var headers: [String: String] = [:]
        if self._resource.size > 0 {
            headers[HTTPHeader.RANGE] = "bytes=\(self._resource.size)-"
        }
        self._task = DownloadTaskManagerHolder.instance.create(url, headers: headers)
        if self._task == nil {
            print("AbstractHttpDownloaderProxy._buildPayload _task nil \(url)")
        }
        self._aborter.task = self._task
        await self._task?.done()
        try await self._task?.throwIfError()
    }

    func _handleEntireContent() async {
        await self._concatResourceChunk(false)
        await self._updateResourceType()
        await self._updateResourceTotal()
    }

    func _handlePartialContent() async {
        await self._concatResourceChunk(true)
        await self._updateResourceType()
        await self._updateResourceTotal()
    }

    func _handleInvalidContent() async throws {
        throw InternalError(MessageCode.ESC011, nil, ["payload": self._task ?? ""])
    }

    func _concatResourceChunk(_ isPartial: Bool) async {
        //        var downloadedSize = 0
        //        if (isPartial) {
        //            downloadedSize = _resource.size
        //        }
        //        for chunk in _payload!.body {
        //           await _resource.concat(
        //                chunk,
        //                range: downloadedSize ... downloadedSize + chunk.length
        //            )
        //            downloadedSize += chunk.length
        //        }
    }

    func _updateResourceType() async {
        //        _resource.type = _payload.response!.headers.get(HTTPHeader.CONTENT_TYPE)!.split('')[0].toLowerCase()
    }

    func _updateResourceTotal() async {
        //        _resource.total = _resource.size
    }

    override func _abort() async {
        self._aborter.abort()
    }
}

typealias PerformanceResourceTiming = WatchTool

class MCDNDownloaderProxy: AbstractHttpDownloaderProxy {
    var _error: Error?
    var _source: CDN!
    var _sources: Queue<CDN>?
    var _startSize: Int!
    var _startTime: TimeInterval!
    var _endTime: TimeInterval!
    var _measurement: PerformanceResourceTiming = .init()
    var _backoff = Backoff(
        delayer: ExponentialDelayer(),
        multiplier: 1.1,
        maxInterval: 5,
        maxAttempts: -1
    )
    
    var _shouldRetry: Bool {
        return self._sources?.first != nil
    }

    var _isWithinInitialTimeout: Bool {
        let timeout = KernelSettings.instance.download.httpInitialTimeout * Double(_resource.priority)
        return !_resource.ctime.hasElapsedTimeS(timeout)
    }

    required init(
        _ _resource: Resource)
    {
        super.init(_resource)
    }

    override func _setup() async throws {
        await self._resetStates()
        try await self._checkStates()
        await self._ensureSources()
        try await self._fetchSource()
        await self._buildRequestURI()
    }

    func _resetStates() async {
        self._error = nil
        self._startSize = _resource.size
        self._startTime = Date.now()
    }

    func _checkStates() async throws {
        if !_resource.isShareable {
            return
        }
        if self._isWithinInitialTimeout {
            throw InternalError(MessageCode.ESC012)
        }
    }

    func _ensureSources() async {
        if self._sources == nil {
            let sel = MCDNSelector.process(
                resource: _resource
            )
            self._sources = .init(sel._outcome)
        }
    }

    func _fetchSource() async throws {
        self._source = self._sources?.removeFirst()
    }

    func _buildRequestURI() async {
        var url = URLComponents(string: _resource.uri)
        url?.scheme = "https"
        url?.port = nil
        url?.host = self._source.domain
        url?.fragment = nil
        Logger.debug("mcdn download url=\(url?.url?.absoluteString ?? "nil")")
        self._requestURI = url!.url!.absoluteString
    }

    override func _fetch() async throws {
        await self._buildMeasurement()
        try await super._fetch()
        await self._stopMeasurement()
        Task {
            await self._recordDownload()
        }
        await self._clearPerformance()
    }

    override func fetch() async throws {
        while true {
            do {
                try await self._setup()
                try await self._fetch()
                break
            } catch {
                Logger.error("download error MCDNDownloaderProxy.fetch \(_requestURI!)")
                Logger.error("", error)
                if !self._shouldRetry {
                    throw error
                }
            }
        }
    }

    func _buildMeasurement() async {
        self._watch.start()
    }

    func _stopMeasurement() async {
        _ = self._watch.stop()
        Logger.debug("mcdn download url=\(_requestURI ?? "nil") cost=\(_watch.elapsedTimeS())")
    }

    func _recordDownload() async {
        await MCDNDownloadRecorder.process(
            MCDNDownloadRecorderOptions(
                source: self._source,
                resource: _resource,
                payload: _task,
                error: self._error,
                aborter: _aborter,
                requestURI: _requestURI,
                startSize: self._startSize,
                startTime: self._startTime,
                measurement: self._measurement
            )
        )
    }

    func _clearPerformance() async {}
}

class CDNOriginKeeper {
    private static var host: String?

    static func setOrigin(_ url: String) {
        let uc = URLComponents(string: url)
        Self.host = uc?.host
    }

    static func getOrigin(_ url: URL) -> URL {
        var uc = URLComponents(url: url, resolvingAgainstBaseURL: false)
        uc?.scheme = "https"
        uc?.host = Self.host
        uc?.port = nil
        return uc?.url ?? url
    }
}
