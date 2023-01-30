class SystemInitializer: Flow {
    override func process() async -> Any? {
        _ = await UpdateServerHostsHandler().process()
        async let token = UpdateClientTokenHandler().process()
        async let client = UpdateClientConfigHandler().process()
        async let system = UpdateSystemConfigHandler().process()
        _ = await [token, client, system]

        return true
    }
}

class SystemDeinitializer: Flow {
    override func process() async -> Any? {
        KernelSettings.instance = KernelSettings()
        return KernelSettings.instance
    }
}

class UpdateServerHostsHandler: Flow {
    override func process() async -> Any? {
        Logger.debug("ReadHostsFlow process")
        guard let resp = try? await HostRequester().readHosts() else {
            Logger.error("ReadHostsFlow ERROR")
            return nil
        }
        KernelSettings.instance.server.token.fqdn = resp.token!
        KernelSettings.instance.server.config.fqdn = resp.config!
        KernelSettings.instance.server.metering.fqdn = resp.metering!
        KernelSettings.instance.server.cdnScore.fqdn = resp.score!
        KernelSettings.instance.server.tracker.fqdns = resp.websocket!
        return resp
    }
}

class UpdateClientTokenHandler: Flow {
    func intakeNonce() -> Int {
        return Int(Date.now())
    }

    func intakeSignature() -> String {
        let id = KernelSettings.instance.client.id!
        let key = KernelSettings.instance.client.key!
        let origin = KernelSettings.instance.client.origin!
        let nonce = intakeNonce()
        let hashed1 = HashTool.SHA256Base16(String(nonce))!
        let hashed2 = HashTool.SHA256Base16("\(origin)\(id)\(hashed1)")!
        let signature = HashTool.SHA256Base64URL("\(key)\(hashed2)")!
        return signature
    }

    override func process() async -> Any? {
        Logger.debug("ReadTokenFlow process")
        var options = TokenRequesterReadTokenOptions()
        options.clientID = KernelSettings.instance.client.id
        options.origin = KernelSettings.instance.client.origin
        options.nonce = intakeNonce()
        options.signature = intakeSignature()

        guard let resp = try? await TokenRequester().readToken(options: options) else {
            Logger.error("ReadTokenFlow ERROR")
            return nil
        }

        KernelSettings.instance.client.token = resp.data.token
        KernelSettings.instance.client.peerID = resp.data.peerID

        return resp
    }
}

class UpdateClientConfigHandler: Flow {
    override func process() async -> Any? {
        Logger.debug("ClientConfigFlow process")
        var options = ConfigRequesterReadClientConfigOptions()
        options.clientID = KernelSettings.instance.client.id
        guard let resp = try? await ConfigRequester().readClientConfig(options: options) else {
            Logger.error("ClientConfigFlow ERROR")
            return nil
        }

        KernelSettings.instance.system.mode = resp.mode ?? "none"
        KernelSettings.instance.system.isP2PAllowed = resp.mode?.contains("p2p") ?? false
        KernelSettings.instance.report.isEnabled = resp.enable_metering_report ?? false
        KernelSettings.instance.report.sampleRate = resp.metering_report?.sample_rate ?? 1.0
        
        KernelSettings.instance.stream.streamID = resp.stream_id ?? "null"

        return resp
    }
}

class UpdateSystemConfigHandler: Flow {
    override func process() async -> Any? {
        Logger.debug("PlatformConfigFlow process")
        var options = ConfigRequesterReadPlatformConfigOptions()
        options.clientID = KernelSettings.instance.client.id
        guard let resp = try? await ConfigRequester().readPlatformConfig(options: options) else {
            Logger.error("PlatformConfigFlow ERROR")
            return nil
        }

        KernelSettings.instance.platforms = resp
        guard let platforms = resp.platforms else {
            Logger.error("PlatformConfigFlow ERROR: nil platforms")
            return nil
        }
        for platform in platforms {
            let cdn = CDN()
            cdn.domain = platform.host
            cdn.id = platform.id
            cdn.businessScore = platform.score ?? 1
            cdn.currentScore = platform.score ?? 1
            cdn.isEnabled = platform.enable
            cdn.name = platform.name
            if let id = cdn.id {
                MCDNStatsHolder.cdns[id] = cdn
            }
        }
        return resp
    }
}

enum FlowValueHolder {
    static var instance: FlowValue = .init()
}

class FlowValue {}
