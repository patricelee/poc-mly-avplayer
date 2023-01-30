import Foundation
import GCDWebServer

class ProxyComponent: Component {
    static var instance: ProxyComponent?
    private var usePort: UInt = 34567
    private var server: GCDWebServer?
    private var task: Task<Void, Never>?
    override var isRunning: Bool {
        get {
            return self.server?.isRunning ?? false
        }
        set {}
    }

    override init() {
        super.init()
        Self.instance = self
        self.task = Task.detached(priority: .background) { [unowned self] in
            await self.keepAlive()
        }
    }

    deinit {
        self.task?.cancel()
        self.task = nil
    }

    func reset() {
        self.isActivated = false
        if let server = self.server {
            server.removeAllHandlers()
            if server.isRunning {
                server.stop()
            }
            self.server = nil
        }
    }

    override func activate() async {
        self.reset()
        DispatchQueue.main.async { [unowned self] in
            self.createProxy()
            KernelSettings.instance.proxy.port = self.usePort
            self.isActivated = true
        }
    }

    override func deactivate() async {
        self.reset()
    }

    func createProxy() {
        self.server = GCDWebServer()
        self.server?.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, asyncProcessBlock: { request, completion in
            Task.detached(priority: .background) {
                let res = await self.handle(request) ?? GCDWebServerDataResponse(statusCode: 404)
                completion(res)
            }
        })
        let started = self.server?.start(withPort: self.usePort, bonjourName: nil) ?? false
        if started {
            Logger.debug("Proxy create SUCCESS port:\(self.usePort)")
        } else {
            Logger.error("Proxy create FAILED port:\(self.usePort)")
            self.changePort()
        }
    }

    func changePort() {
        self.usePort = UInt(10_000 + arc4random_uniform(65_535 - 10_000))
    }

    func handle(_ request: GCDWebServerRequest?) async -> GCDWebServerResponse? {
        Logger.debug("proxy: start \(request?.url.absoluteString ?? "nil url")")
        guard let url = request?.url else {
            Logger.error("proxy: nil url")
            return nil
        }
        let origin = CDNOriginKeeper.getOrigin(url)
        Logger.debug("proxy: origin \(origin.absoluteString)")
        guard let res = await HLSLoader.load(origin.absoluteString) else {
            Logger.error("proxy: nil resource")
            return nil
        }
        guard let content = res.content else {
            Logger.error("proxy: nil data")
            return nil
        }
        if res.type == nil {
            res.type = ContentType(url: url).rawValue
        }
        Logger.debug("proxy: done \(request!.url.absoluteString) count=\(content.count) ")
        return GCDWebServerDataResponse(data: content, contentType: res.type!)
    }

    func keepAlive() async {
        while true {
            if self.task?.isCancelled ?? false {
                break
            }
            if self.isActivated && !self.isRunning {
                await self.activate()
            }
            await TaskTool.delay(seconds: 10)
        }
    }
}
