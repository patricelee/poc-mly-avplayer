

class DomainMetricsCount: Codable {
    var usage = DomainMetricsUsage()
    var success = DomainMetricsUsage()
    var failure = DomainMetricsUsage()
}

class DomainMetricsDownload: Codable {
    var count = DomainMetricsCount()
    var outcome = DomainMetricsUsage()
    var traffic = DomainMetricsUsage()
    var bandwidth = DomainMetricsBandwidth()
}

class DomainMetricsUsage: DataSet {
    var pulse = DataSet()
    var cumulation = DataSet()
}

class DataSet: Codable {
    var dataset: [TimeSeriesData<Double>] = []
}

class DataSetLast: DataSet {
    var last = DataSet()
}

class DomainMetricsBandwidth: DataSet {
    var wma = DataSet()
}

class DomainMetrics: Codable {
    var id: String?
    var type: String?

    var name: String?
    var domain: String?
    var isEnabled: Bool?

    var download: DomainMetricsDownload?
}

class CDNMetricsDownload: DomainMetricsDownload {
    var meanBandwidth = DataSetLast()
    var meanAvailability = DataSetLast()
    var currentScore = DataSetLast()
}

class CDNMetrics: DomainMetrics {
    
    var cdndownload: CDNMetricsDownload? {
        get {
            return download as? CDNMetricsDownload
        }
        set {
            download = newValue
        }
    }
}

typealias OriginMetrics = DomainMetrics
struct TrackerMetrics: Codable {
    var peerID: String?
    var isAvailable: Bool?
}

struct NodeMetrics: Codable {
    var peerID: String?
    var isAvailable: Bool?
}

struct SwarmMetrics: Codable {
    var swarmID: String?
    var isAvailable: Bool?
    var users: ObjectLike<UserMetrics> = ObjectLike()

    init(swarmID: String? = nil, isAvailable: Bool? = nil) {
        self.swarmID = swarmID
        self.isAvailable = isAvailable
    }
}

struct UserMetrics: Codable {
    var peerID: String?
    var isAvailable: Bool?
    init(peerID: String? = nil, isAvailable: Bool? = nil) {
        self.peerID = peerID
        self.isAvailable = isAvailable
    }
}

class SourceMetrics: Codable {
    var http_download_records: [HTTPDownloadRecord] = []
    var p2p_download_records: [P2PDownloadRecord] = []
}

struct TimeSeriesData<T: Codable>: Codable {
    var value: T?
    var ctime: TimeInterval?
    init(_ value: T? = nil, ctime: TimeInterval? = Date.now()) {
        self.value = value
        self.ctime = ctime
    }
}

extension TimeSeriesData where T: Equatable {
    static func == (lhs: TimeSeriesData<T>, rhs: TimeSeriesData<T>) -> Bool {
        return lhs.ctime == rhs.ctime && lhs.value == rhs.value
    }
}
