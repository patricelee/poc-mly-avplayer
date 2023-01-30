

typealias HTTPDownloadRecordExport = HTTPDownloadRecord
struct HTTPDownloadPulseTrafficExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct HTTPDownloadCumulativeTrafficExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct HTTPDownloadWMABandwidthExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct HTTPDownloadUsagePulseCountExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct HTTPDownloadUsageCumulativeCountExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
    
}

struct HTTPDownloadSuccessPulseCountExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct HTTPDownloadSuccessCumulativeCountExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct HTTPDownloadFailurePulseCountExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
    
}

struct HTTPDownloadFailureCumulativeCountExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct CDNDownloadLastMeanBandwidthExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct CDNDownloadLastMeanAvailabilityExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>]? = []
    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

struct CDNDownloadLastCurrentScoreExport {
    var id: String?
    var name: String?
    var type: String?
    var domain: String?
    var isEnabled: Bool?
    var dataset: [TimeSeriesData<Double>] = []

    init(id: String? = nil, name: String? = nil, type: String? = nil, domain: String? = nil, isEnabled: Bool? = nil, dataset: [TimeSeriesData<Double>]) {
        self.id = id
        self.name = name
        self.type = type
        self.domain = domain
        self.isEnabled = isEnabled
        self.dataset = dataset
    }
}

typealias P2PDownloadRecordExport = P2PDownloadRecord
struct P2SPSystemStateExport {
    var tracker: TrackerMetrics
    var node: NodeMetrics
    var swarms: ObjectLike<SwarmMetrics>
    init(tracker: TrackerMetrics, node: NodeMetrics, swarms: ObjectLike<SwarmMetrics>) {
        self.tracker = tracker
        self.node = node
        self.swarms = swarms
    }
}
