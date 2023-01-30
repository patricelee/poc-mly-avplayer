class DownloaderProxyName: BaseDownloaderProxyName {
    static let MCDN = "mcdn"
    static let NODE = "node"
    static let USER = "user"
}

class NodeDownloaderProxy: AbstractDownloaderProxy {}

class UserDownloaderProxy: AbstractDownloaderProxy {}

class DownloaderAgent: AbstractDownloaderAgent {
    static let PROXY_NAMES: [String: [String]] = [
        SystemModeName.MCDN_ONLY:
            [
                DownloaderProxyName.MCDN
            ],
        SystemModeName.P2P_MCDN:
            [
//                DownloaderProxyName.USER,
                DownloaderProxyName.MCDN
            ],
        SystemModeName.P2P_P2S:
            [
//                DownloaderProxyName.USER,
//                DownloaderProxyName.NODE
            ],
        SystemModeName.P2S_ONLY:
            [
//                DownloaderProxyName.NODE
            ]
    ]

    static let PROXY_CLASSES: [String: AbstractDownloaderProxy.Type] = [
        DownloaderProxyName.MCDN:
            MCDNDownloaderProxy.self,

        DownloaderProxyName.NODE:
            NodeDownloaderProxy.self,

        DownloaderProxyName.USER:
            UserDownloaderProxy.self
    ]

    override var _proxyNames: [String] {
        let mode = KernelSettings.instance.system.mode
        return DownloaderAgent.PROXY_NAMES[mode]!
    }

    override var _proxyClasses: [String: AbstractDownloaderProxy.Type] {
        return DownloaderAgent.PROXY_CLASSES
    }
}

enum DownloadTaskManagerHolder {
    static var instance: DownloadTaskManager = .init(KernelSettings.instance.download.httpResponseTimeout)
}
