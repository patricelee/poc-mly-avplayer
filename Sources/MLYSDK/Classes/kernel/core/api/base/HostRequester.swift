class HostRequester: Requester {
    override init() { super.init(KernelSettings.instance.server.host.fqdn, timeout: KernelSettings.instance.download.httpResponseTimeout)
    }

    func readHosts() async throws -> HostResponse? { return try await fetch("/host.json", type: HostResponse.self)
    }
}

class TokenRequester: Requester {
    override init() { super.init(KernelSettings.instance.server.token.fqdn, timeout: KernelSettings.instance.download.httpResponseTimeout)
    }

    func readToken(options: TokenRequesterReadTokenOptions) async throws -> TokenResponse? { return try await fetch("/token/jwt/", type: TokenResponse.self, queries: ["client_id": options.clientID], headers: ["origin": options.origin, "nonce": String(options.nonce!), "signature": options.signature])
    }

    func renewToken(options: TokenRequesterRenewTokenOptions) async throws -> TokenResponse? { return try await fetch("/token/jwt/renew/", type: TokenResponse.self, queries: ["client_id": options.clientID], headers: ["origin": options.origin, "nonce": String(options.nonce!), "signature": options.signature, "authorization": "token \(options.token!)"])
    }
}

class ConfigRequester: Requester {
    override init() { super.init(KernelSettings.instance.server.config.fqdn, timeout: KernelSettings.instance.download.httpResponseTimeout)
    }

    func readClientConfig(options: ConfigRequesterReadClientConfigOptions) async throws -> ClientConfigResponse? { return try await fetch("/\(options.clientID!)-config.json", type: ClientConfigResponse.self)
    }

    func readPlatformConfig(options: ConfigRequesterReadPlatformConfigOptions) async throws -> PlatformConfigResponse? { return try await fetch("/\(options.clientID!)-platforms.json", type: PlatformConfigResponse.self)
    }
}

class CDNScoreRequester: Requester {
    override init() { super.init(KernelSettings.instance.server.cdnScore.fqdn, timeout: KernelSettings.instance.download.httpResponseTimeout)
    }

    func readPlatformScores(options: CDNScoreRequesterReadPlatformScoresOptions) async throws -> CDNScoreAPIReadPlatformScoresOutcome? { return try await fetch("/scorer/algorithms/\(options.algorithmID!)/scores/", type: CDNScoreAPIReadPlatformScoresOutcome.self, queries: ["platforms[]": options.platformIDs, "stream_id": KernelSettings.instance.stream.streamID])
    }
}

class MeteringRequester: Requester {
    override init() { super.init(KernelSettings.instance.server.metering.fqdn, timeout: KernelSettings.instance.download.httpResponseTimeout)
    }

    func createCDNDownloadMetering(options: MeteringAPICreateCDNDownloadMeteringData) async throws -> RequesterResult? { return try await fetch("/metering/", queries: ["data": options])
    }

    func createP2PDownloadMetering(options: MeteringAPICreateP2PDownloadMeteringOptions) async throws -> RequesterResult? { return try await fetch("/p2p-metering/", queries: ["data": options])
    }
}
