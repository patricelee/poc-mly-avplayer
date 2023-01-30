import Foundation

struct HostResponse: Codable {
    var token: String?
    var config: String?
    var score: String?
    var metering: String?
    var websocket: [String?]?
}

struct TokenResponse: Codable {
    var data: TokenDataResponse
    var meta: TokenMetaResponse
}

struct TokenDataResponse: Codable {
    var peerID: String?
    var token: String?
}

struct TokenMetaResponse: Codable {
    var code: Int?
    var message: String?
    var status: String?
}

struct TokenRequesterReadTokenOptions: Codable {
    var clientID: String?
    var origin: String?
    var nonce: Int?
    var signature: String?
}

struct TokenRequesterRenewTokenOptions: Codable {
    var clientID: String?
    var origin: String?
    var nonce: Int?
    var signature: String?
    var token: String?
}

struct ConfigRequesterReadClientConfigOptions {
    var clientID: String?
}

struct ConfigRequesterReadPlatformConfigOptions {
    var clientID: String?
}

struct ClientConfigResponse: Codable {
    var client_id: String?
    var enable_metering_report: Bool?
    var metering_report: ClientConfigMeteringReportResponse?
    var mode: String?
    var stream_id: String?
}

struct ClientConfigMeteringReportResponse: Codable {
    var enable: Bool?
    var sample_rate: Double?
}

struct PlatformConfigResponse: Codable {
    var algorithm_id: String?
    var algorithm_ver: String?
    var platforms: [PlatformConfigPlatformResponse]?
}

class PlatformConfigPlatformResponse: Codable {
    var enable: Bool?
    var host: String?
    var id: String?
    var name: String?
    var score: Double?
}

struct CDNScoreRequesterReadPlatformScoresOptions: Codable {
    var algorithmID: String?
    var platformIDs: [String]?
}

struct CDNScoreAPIReadPlatformScoresOutcome: Codable {
    var platforms: [CDNScoreAPIReadPlatformScore]?
}

struct CDNScoreAPIReadPlatformScore: Codable {
    var id: String?
    var score: Double?
}

struct MeteringAPICreateCDNDownloadMeteringData: Codable {
    var data: [MeteringAPICreateCDNDownloadMeteringDataItem]
    init(data: [MeteringAPICreateCDNDownloadMeteringDataItem]) {
        self.data = data
    }
}

struct MeteringAPICreateCDNDownloadMeteringDataItem: Codable {
    var time: TimeInterval?
    var streamID: String?
    var clientID: String?
    var sessionID: String?
    var ok: Bool?
    var error: String?
    var httpCode: Int?
    var url: String?
    var masterURL: String?
    var sourceURL: String?
    var hostname: String?
    var platformID: String?
    var transferSize: Int?
    var duration: TimeInterval?
    var isComplete: Bool?
    var sampleRate: Double?
    var algorithmID: String?
    var algorithmVer: String?
    init(time: TimeInterval? = nil, streamID: String? = nil, clientID: String? = nil, sessionID: String? = nil, ok: Bool? = nil, error: String? = nil, httpCode: Int? = nil, url: String? = nil, masterURL: String? = nil, sourceURL: String? = nil, hostname: String? = nil, platformID: String? = nil, transferSize: Int? = nil, duration: TimeInterval? = nil, isComplete: Bool? = nil, sampleRate: Double? = nil, algorithmID: String? = nil, algorithmVer: String? = nil) {
        self.time = time
        self.streamID = streamID
        self.clientID = clientID
        self.sessionID = sessionID
        self.ok = ok
        self.error = error
        self.httpCode = httpCode
        self.url = url
        self.masterURL = masterURL
        self.sourceURL = sourceURL
        self.hostname = hostname
        self.platformID = platformID
        self.transferSize = transferSize
        self.duration = duration
        self.isComplete = isComplete
        self.sampleRate = sampleRate
        self.algorithmID = algorithmID
        self.algorithmVer = algorithmVer
    }
}

struct MeteringAPICreateCDNDownloadMeteringContent: Codable {
    var records: [MeteringAPICreateCDNDownloadMeteringContentItem]
    init(records: [MeteringAPICreateCDNDownloadMeteringContentItem]) {
        self.records = records
    }
}

struct MeteringAPICreateCDNDownloadMeteringContentItem: Codable {
    var id: String?
    var contentSize: Int?
    var startTime: Double?
    var elapsedTime: Double?
    var isSuccess: Bool?
    var isComplete: Bool?
    var swarmURI: String?
    var sourceURI: String?
    var requestURI: String?
    var responseCode: Int?
    var errorMessage: String?
    var algorithmID: String?
    var algorithmVersion: String?
    init(id: String? = nil, contentSize: Int? = nil, startTime: Double? = nil, elapsedTime: Double? = nil, isSuccess: Bool? = nil, isComplete: Bool? = nil, swarmURI: String? = nil, sourceURI: String? = nil, requestURI: String? = nil, responseCode: Int? = nil, errorMessage: String? = nil, algorithmID: String? = nil, algorithmVersion: String? = nil) {
        self.id = id
        self.contentSize = contentSize
        self.startTime = startTime
        self.elapsedTime = elapsedTime
        self.isSuccess = isSuccess
        self.isComplete = isComplete
        self.swarmURI = swarmURI
        self.sourceURI = sourceURI
        self.requestURI = requestURI
        self.responseCode = responseCode
        self.errorMessage = errorMessage
        self.algorithmID = algorithmID
        self.algorithmVersion = algorithmVersion
    }
}

struct MeteringAPICreateP2PDownloadMeteringContent: Codable {
    var records: [MeteringAPICreateP2PDownloadMeteringContentItem]
    init(records: [MeteringAPICreateP2PDownloadMeteringContentItem]) {
        self.records = records
    }
}

struct MeteringAPICreateP2PDownloadMeteringContentItem: Codable {
    var peerID: String?
    var contentSize: Int?
    var startTime: TimeInterval?
    var elapsedTime: TimeInterval?
    var isComplete: Bool?
    var swarmURI: String?
    var sourceURI: String?
    var requestURI: String?
    var algorithmID: String?
    var algorithmVersion: String?
    init(peerID: String? = nil, contentSize: Int? = nil, startTime: TimeInterval? = nil, elapsedTime: TimeInterval? = nil, isComplete: Bool? = nil, swarmURI: String? = nil, sourceURI: String? = nil, requestURI: String? = nil, algorithmID: String? = nil, algorithmVersion: String? = nil) {
        self.peerID = peerID
        self.contentSize = contentSize
        self.startTime = startTime
        self.elapsedTime = elapsedTime
        self.isComplete = isComplete
        self.swarmURI = swarmURI
        self.sourceURI = sourceURI
        self.requestURI = requestURI
        self.algorithmID = algorithmID
        self.algorithmVersion = algorithmVersion
    }
}

struct MeteringAPICreateP2PDownloadMeteringOptions: Codable {
    var data: [MeteringAPICreateP2PDownloadMeteringOptionsItem]
    init(data: [MeteringAPICreateP2PDownloadMeteringOptionsItem]) {
        self.data = data
    }
}

struct MeteringAPICreateP2PDownloadMeteringOptionsItem: Codable {
    var time: TimeInterval?
    var streamID: String?
    var clientID: String?
    var sessionID: String?
    var peerID: String?
    var peerType: String?
    var targetPeerID: String?
    var targetPeerType: String?
    var url: String?
    var masterURL: String?
    var sourceURL: String?
    var transferType: String?
    var transferSize: Int?
    var duration: TimeInterval?
    var isComplete: Bool?
    var sampleRate: Double?
    var algorithmID: String?
    var algorithmVer: String?
    init(time: TimeInterval? = nil, streamID: String? = nil, clientID: String? = nil, sessionID: String? = nil, peerID: String? = nil, peerType: String? = nil, targetPeerID: String? = nil, targetPeerType: String? = nil, url: String? = nil, masterURL: String? = nil, sourceURL: String? = nil, transferType: String? = nil, transferSize: Int? = nil, duration: TimeInterval? = nil, isComplete: Bool? = nil, sampleRate: Double? = nil, algorithmID: String? = nil, algorithmVer: String? = nil) {
        self.time = time
        self.streamID = streamID
        self.clientID = clientID
        self.sessionID = sessionID
        self.peerID = peerID
        self.peerType = peerType
        self.targetPeerID = targetPeerID
        self.targetPeerType = targetPeerType
        self.url = url
        self.masterURL = masterURL
        self.sourceURL = sourceURL
        self.transferType = transferType
        self.transferSize = transferSize
        self.duration = duration
        self.isComplete = isComplete
        self.sampleRate = sampleRate
        self.algorithmID = algorithmID
        self.algorithmVer = algorithmVer
    }
    
    
}
