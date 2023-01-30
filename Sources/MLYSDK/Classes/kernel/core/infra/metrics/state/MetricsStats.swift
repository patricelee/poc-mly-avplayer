

class MetricsStats {
    var _cdns: ObjectLike<CDNMetrics>!
    var _origin: OriginMetrics!
    var _tracker: TrackerMetrics!
    var _node: NodeMetrics!
    var _swarms: ObjectLike<SwarmMetrics>!
    var _source: SourceMetrics!
    init() {
        self.reset()
    }

    func cdns() -> ObjectLike<CDNMetrics> {
        return self._cdns
    }

    func origin() -> OriginMetrics {
        return self._origin
    }

    func tracker() -> TrackerMetrics {
        return self._tracker
    }

    func node() -> NodeMetrics {
        return self._node
    }

    func swarms() -> ObjectLike<SwarmMetrics> {
        return self._swarms
    }

    func source() -> SourceMetrics {
        return self._source
    }

    func reset() {
        self._resetMCDN()
        self._resetP2SP()
        self._resetSource()
    }

    func resetMCDN() {
        self._resetMCDN()
    }

    func _resetMCDN() {
        self._setupCDNs()
        self._setupOrigin()
    }

    func _resetP2SP() {
        self._setupTracker()
        self._setupNode()
        self._setupSwarms()
    }

    func _resetSource() {
        self._setupSource()
    }

    func setupCDN(_ record: CDNConfigRecord) {
        self._setupCDN(record)
    }

    func setupSwarm(_ record: SwarmStateRecord) {
        self._setupSwarm(record)
    }

    func setupUser(_ record: UserStateRecord) {
        self._setupUser(record)
    }

    func _setupCDNs() {
        self._cdns = ObjectLike()
    }

    func _setupCDN(_ record: CDNConfigRecord) {
        let value = CDNMetrics()
        self._cdns[record.id!] = value

        value.id = record.id
        value.name = record.name
        value.type = record.type
        value.domain = record.domain
        value.isEnabled = record.isEnabled

        let download = CDNMetricsDownload()
        value.download = download
        download.meanBandwidth.dataset.append(TimeSeriesData(record.meanBandwidth))
        download.meanAvailability.dataset.append(TimeSeriesData(record.meanAvailability))
        download.currentScore.dataset.append(TimeSeriesData(record.currentScore))
    }

    func _setupOrigin() {
        let value = OriginMetrics()
        value.type = DomainType.ORIGIN.rawValue
        self._origin = value
    }

    func _setupTracker() {
        self._tracker = TrackerMetrics()
    }

    func _setupNode() {
        self._node = NodeMetrics()
    }

    func _setupSwarms() {
        self._swarms = ObjectLike()
    }

    func _setupSwarm(_ record: SwarmStateRecord) {
        self._swarms[record.swarmID!] = SwarmMetrics(swarmID: record.swarmID, isAvailable: record.isAvailable)
    }

    func _setupUser(_ record: UserStateRecord) {
        self._swarms[record.swarmID!]!.users[record.peerID!] = UserMetrics(
            peerID: record.peerID, isAvailable: record.isAvailable
        )
    }

    func _setupSource() {
        self._source = SourceMetrics()
    }
}

class MetricsStatsHolder {
    static var _instance: MetricsStats?
    static var instance: MetricsStats? {
        get {
            return self._instance
        }
        set {
            self._instance = newValue
        }
    }

    static var cdns: ObjectLike<CDNMetrics> {
        return Self._instance!.cdns()
    }

    static var origin: OriginMetrics {
        return Self._instance!.origin()
    }

    static var tracker: TrackerMetrics {
        return Self._instance!.tracker()
    }

    static var node: NodeMetrics {
        return Self._instance!.node()
    }

    static var swarms: ObjectLike<SwarmMetrics> {
        return Self._instance!.swarms()
    }

    static var source: SourceMetrics {
        return Self._instance!.source()
    }

    static func resetMCDN() {
        Self._instance!.resetMCDN()
    }

    static func setupCDN(_ record: CDNConfigRecord) {
        Self._instance!.setupCDN(record)
    }

    static func setupSwarm(_ record: SwarmStateRecord) {
        Self._instance!.setupSwarm(record)
    }

    static func setupUser(_ record: UserStateRecord) {
        Self._instance!.setupUser(record)
    }
}
