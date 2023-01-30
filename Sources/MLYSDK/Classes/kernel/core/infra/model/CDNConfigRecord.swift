struct CDNConfigRecord:Codable {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var meanBandwidth: Double?
    var meanAvailability: Double?
    var currentScore: Double?
}

struct CDNDownloadRecord:Codable {
    var ctime: TimeInterval?
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var meanBandwidth: Double?
    var meanAvailability: Double?
    var currentScore: Double?
    init(ctime: TimeInterval? = nil, id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, meanBandwidth: Double? = nil, meanAvailability: Double? = nil, currentScore: Double? = nil) {
        self.ctime = ctime
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.meanBandwidth = meanBandwidth
        self.meanAvailability = meanAvailability
        self.currentScore = currentScore
    }
}

struct HTTPDownloadRecord:Codable, Equatable {
    var ctime: TimeInterval?
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var totalSize: Int?
    var contentType: String?
    var contentSize: Int?
    var startTime: TimeInterval?
    var elapsedTime: TimeInterval?
    var bandwidth: Double?
    var isAborted: Bool?
    var isSuccess: Bool?
    var isOutlier: Bool?
    var isComplete: Bool?
    var swarmID: String?
    var swarmURI: String?
    var sourceURI: String?
    var requestURI: String?
    var responseCode: Int?
    var errorMessage: String?
    var algorithmID: String?
    var algorithmVersion: String?
    init(ctime: TimeInterval? = nil, id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, totalSize: Int? = nil, contentType: String? = nil, contentSize: Int? = nil, startTime: TimeInterval? = nil, elapsedTime: TimeInterval? = nil, bandwidth: Double? = nil, isAborted: Bool? = nil, isSuccess: Bool? = nil, isOutlier: Bool? = nil, isComplete: Bool? = nil, swarmID: String? = nil, swarmURI: String? = nil, sourceURI: String? = nil, requestURI: String? = nil, responseCode: Int? = nil, errorMessage: String? = nil, algorithmID: String? = nil, algorithmVersion: String? = nil) {
        self.ctime = ctime
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.totalSize = totalSize
        self.contentType = contentType
        self.contentSize = contentSize
        self.startTime = startTime
        self.elapsedTime = elapsedTime
        self.bandwidth = bandwidth
        self.isAborted = isAborted
        self.isSuccess = isSuccess
        self.isOutlier = isOutlier
        self.isComplete = isComplete
        self.swarmID = swarmID
        self.swarmURI = swarmURI
        self.sourceURI = sourceURI
        self.requestURI = requestURI
        self.responseCode = responseCode
        self.errorMessage = errorMessage
        self.algorithmID = algorithmID
        self.algorithmVersion = algorithmVersion
    }
    
}

struct P2PDownloadRecord:Codable, Equatable {
    var ctime: TimeInterval?
    var peerID: String?
    var totalSize: Int?
    var contentType: String?
    var contentSize: Int?
    var startTime: TimeInterval?
    var elapsedTime: TimeInterval?
    var bandwidth: Double?
    var isOutlier: Bool?
    var isComplete: Bool?
    var swarmID: String?
    var swarmURI: String?
    var sourceURI: String?
    var requestURI: String?
    var algorithmID: String?
    var algorithmVersion: String?
}

struct TrackerStateRecord:Codable {
    var peerID: String?
    var isAvailable: Bool?
}

struct NodeStateRecord:Codable {
    var peerID: String?
    var isAvailable: Bool?
}

struct SwarmStateRecord:Codable {
    var swarmID: String?
    var isAvailable: Bool?
}

struct UserStateRecord:Codable {
    var peerID: String?
    var swarmID: String?
    var isAvailable: Bool?
}

