import SwiftCentrifuge

class CentrifugeComponent: Component {
    static var instance: CentrifugeComponent?
    var client: CentrifugeClient?
    override init() {
        super.init()
        Self.instance = self
    }

    override var isRunning: Bool {
        get {
            return self.client?.state == .connected
        }
        set {}
    }

    override func activate() async {
        await super.activate()
        _activate()
    }

    override func deactivate() async {
        await super.deactivate()
        self.client?.disconnect()
        self.client = nil
    }

    func _activate() {
        guard let host = KernelSettings.instance.server.tracker.fqdns.shuffled().first ?? nil else {
            Logger.error("CentrifugeComponent tracker host nil")
            return
        }
        var config = CentrifugeClientConfig()
        config.token = KernelSettings.instance.client.token
        config.timeout = 20
        let endpoint = "wss://\(host)/centrifugo/connection/websocket"
        Logger.debug("wss connecting url=\(endpoint) token=\(config.token ?? "nil")")
        self.client = CentrifugeClient(endpoint: endpoint, config: config, delegate: ClientDelegate())
        self.client?.connect()
    }
}

class ClientDelegate: NSObject, CentrifugeClientDelegate {
    func onConnecting(_ c: CentrifugeClient, _ event: CentrifugeConnectingEvent) {
        print("ClientDelegate connecting", event.code, event.reason)
    }

    func onConnected(_ client: CentrifugeClient, _ event: CentrifugeConnectedEvent) {
        print("ClientDelegate connected with id", event.client)
    }

    func onDisconnected(_ client: CentrifugeClient, _ event: CentrifugeDisconnectedEvent) {
        print("ClientDelegate disconnected", event.code, event.reason)
    }

    func onError(_ client: CentrifugeClient, _ event: CentrifugeErrorEvent) {
        print("ClientDelegate onError", event.error)
    }

    func onMessage(_ client: CentrifugeClient, _ event: CentrifugeMessageEvent) {
        print("ClientDelegate onError", event.data)
    }

    func onSubscribed(_ client: CentrifugeClient, _ event: CentrifugeServerSubscribedEvent) {
        print("ClientDelegate onSubscribed", event.channel)
    }

    func onUnsubscribed(_ client: CentrifugeClient, _ event: CentrifugeServerUnsubscribedEvent) {
        print("ClientDelegate onUnsubscribed", event.channel)
    }

    func onSubscribing(_ client: CentrifugeClient, _ event: CentrifugeServerSubscribingEvent) {
        print("ClientDelegate onSubscribing", event.channel)
    }

    func onPublication(_ client: CentrifugeClient, _ event: CentrifugeServerPublicationEvent) {
        print("ClientDelegate onPublication", event.tags)
    }

    func onJoin(_ client: CentrifugeClient, _ event: CentrifugeServerJoinEvent) {
        print("ClientDelegate onJoin", event.user)
    }

    func onLeave(_ client: CentrifugeClient, _ event: CentrifugeServerLeaveEvent) {
        print("ClientDelegate onLeave", event.user)
    }
}
