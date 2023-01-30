import Foundation

//        guard let res = await CacheComponment.default?.get(url) else {
//            return nil
//        }
//        if res.data == nil || res.type == nil {
//            return nil
//        }
//        return GCDWebServerDataResponse(data: res.data!, contentType: res.type!)

class CacheComponment: Component {
    static var instance: CacheComponment?

    deinit {
        Logger.debug("CacheComponment deinit")
        Self.instance = nil
    }

    override init() {
        super.init()
        Self.instance = self
    }

    var cache: Cache<HTTPCacheObject>?

    override func activate() async {
        cache = Cache()
    }

    override func deactivate() async {
        cache?.removeAll()
    }

    func judgeCachable(_ url: URL) -> Bool {
        let type = ContentType(url: url)
        return type == .HLS_TS
    }

    var bytes: Int = 0

    func get(_ url: URL) async -> HTTPCacheObject? {
        let cachable = judgeCachable(url)
        let key = url.path
        if cachable {
            if let res = cache?.get(key) {
                Logger.debug("cache.count \(res.data?.count ?? 0) \(key) \(url)")
                bytes += res.data?.count ?? 0
                return res
            }
        }

        if let res = await MCDNComponent_.instance?.get(url) {
            if cachable {
                _ = cache?.set(key, res, 120)
            }
            return res
        }

        return nil
    }
}

class MCDNComponent_: Component {
    static var instance: MCDNComponent_?

    deinit {
        Logger.debug("MCDNComponent deinit")
        Self.instance = nil
    }

    override init() {
        super.init()
        Self.instance = self
    }

    func host_(_ url: URL) -> String? {
        guard var p = KernelSettings.instance.platforms.platforms else {
            return nil
        }
        if p.isEmpty {
            return nil
        }
        p.sort(by: { a, b in
            (b.score ?? 0) > (a.score ?? 0)
        })
        Logger.debug("host=\(p)")
        return p[0].host
    }

    static func host(_ url: URL) -> String? {
        let options = MCDNSelectorOptions()
        options.resource = Resource(url.absoluteString)
        let sel = MCDNSelector.process(options: options)
        guard let arr = sel._outcome else {
            Logger.error("MCDNSelector error: nil result")
            return url.host
        }
        if arr.isEmpty {
            Logger.error("MCDNSelector error: empty result")
            return url.host
        }
        guard let domain = arr[0].domain else {
            Logger.error("MCDNSelector error: nil domain")
            return url.host
        }
        Logger.debug("MCDNSelector \(domain)")
        return domain
    }

    static func url(_ url: URL) -> URL {
        var cdn = URLComponents()
        cdn.scheme = "https"
        cdn.host = Self.host(url)
        cdn.path = url.path
        cdn.query = url.query

        return cdn.url!
    }

    var bytes: Int = 0
    static var manager = DownloadTaskManager(KernelSettings.instance.download.httpResponseTimeout)

    func get(_ url: URL) async -> HTTPCacheObject? {
        var res = HTTPCacheObject()
        res.url = url
        let cdnUrl = Self.url(url)
        let download = Self.manager.create(cdnUrl)
        guard let download = download else {
            Logger.error("McdnComponent#get nil download \(url), \(cdnUrl)")
            return nil
        }
        await download.done()
        if let error = download.error {
            Logger.error("McdnComponent#get", error)
            return nil
        }
        guard let data = download.data else {
            Logger.error("McdnComponent#get nil data")
            return nil
        }

        Logger.info("proxy.count= \(data.count)")
        bytes += data.count
        res.data = data
        if let resp = download.response {
            res.type = resp.allHeaderFields["Content-Type"] as? String
            if res.type == nil {
                res.type = ContentType(url: url).rawValue
            }
        }
        return res
    }
}
