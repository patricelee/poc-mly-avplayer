import Foundation

enum MCDNConstant {
    static let QUALIFIED_DOWNLOAD_BANDWIDTH = 1.0 * 1024 * 1024
    static let MIN_SIZE_FOR_BANDWIDTH_MEASUREMENT = 16 * 1024
    static let PENALTY_POWER_OF_AVAILABILITY = 3.0
    static let MAX_ACCEPTABLE_SCORE_DIFFERENCE = 0.25
}

class MCDNComponent: MCDNProvider {}

class MCDNInitializer {
    func process() async {
        await self._initializeMCDNStats()
        self._initializeMCDNScores()
        self._forwardCDNConfigRecords()
    }

    func _initializeMCDNStats() async {
        await InitializeMCDNStatsHandler.process()
    }

    func _initializeMCDNScores() {
        InitializeMCDNScoresHandler.process()
    }

    func _forwardCDNConfigRecords() {}

    static func process() async {
        await MCDNInitializer().process()
    }
}

class InitializeMCDNStatsHandler {
    func process() async {
        await self._intakeConfig()
        self._updateStats()
    }

    func _intakeConfig() async {
        guard let platforms = KernelSettings.instance.platforms.platforms else {
            return
        }
        var options = CDNScoreRequesterReadPlatformScoresOptions()
        options.algorithmID = KernelSettings.instance.platforms.algorithm_id
        options.platformIDs = platforms.compactMap { $0.id }
        if let res = try? await CDNScoreRequester().readPlatformScores(options: options) {
            var map: [String: Double] = [:]
            res.platforms?.forEach { map[$0.id ?? ""] = $0.score }
            KernelSettings.instance.platforms.platforms?.forEach {
                $0.score = map[$0.id ?? ""] ?? $0.score
            }
        }
    }

    func _updateStats() {
        guard let platforms = KernelSettings.instance.platforms.platforms else {
            return
        }
        for platform in platforms {
            let cdn = CDN()
            cdn.id = platform.id
            cdn.name = platform.name
            cdn.domain = platform.host
            cdn.type = DomainType.CDN.rawValue
            cdn.isEnabled = platform.enable
            cdn.businessScore = platform.score
            if let id = platform.id {
                MCDNStatsHolder.cdns[id] = cdn
            }
        }

        MCDNStatsHolder.algorithmID = KernelSettings.instance.platforms.algorithm_id
        MCDNStatsHolder.algorithmVersion = KernelSettings.instance.platforms.algorithm_ver
    }

    static func process() async {
        await InitializeMCDNStatsHandler().process()
    }
}

class InitializeMCDNScoresHandler {
    func process() {
        self._intakeConfig()
        self._updateStats()
    }

    func _intakeConfig() {}

    func _updateStats() {
        guard let platforms = KernelSettings.instance.platforms.platforms else {
            return
        }
        for platform in platforms {
            if let id = platform.id {
                MCDNStatsHolder.cdns[id]?.currentScore = platform.score ?? 1
            }
        }
    }

    static func process() {
        InitializeMCDNScoresHandler().process()
    }
}

class MCDNProvider: Component {
    override func activate() async {
        self._loadMCDNStats()
        await self._initializeMCDN()
    }

    func _loadMCDNStats() {
        MCDNStatsHolder.instance = MCDNStats()
    }

    func _initializeMCDN() async {
        await MCDNInitializer.process()
    }

    func deactivate() {
        self._unloadMCDNStats()
        self._purgeMCDNMetrics()
    }

    func _unloadMCDNStats() {
        MCDNStatsHolder.instance?.reset()
        MCDNStatsHolder.instance = nil
    }

    func _purgeMCDNMetrics() {}
}

class MCDNSelector {
    var _content: MCDNSelectorContent?
    var _outcome: [CDN]?
    var _isUrgentResource: Bool {
        if let priority = _content?.resource?.priority {
            return priority < ResourceConstant.URGENT_THRESHOLD_PRIORITY
        }
        return false
    }

    func process() {
        self._intakeResult()
        self._injectOrigin()
        self._intakeOutcome()
    }

    func _intakeResult() {
        var result: [CDN]
        if self._isUrgentResource {
            result = CDNsBasedOnHighScoreGroupHandler.process()
        } else {
            result = CDNsBasedOnOverallScoresHandler.process()
        }
        self._outcome = result.map({ $0 })
    }

    func _injectOrigin() {
        guard var result = self._outcome else {
            return
        }
        guard let resource = self._content!.resource, let url = URL(string: resource.uri) else {
            return
        }
        let originHost = url.host
        for source in result {
            if source.domain == originHost {
                return
            }
        }
        let cdn = CDN()
        cdn.type = DomainType.ORIGIN.rawValue
        cdn.domain = originHost
        result.append(cdn)
        self._outcome = result
    }

    func _intakeOutcome() {}

    static func process(options: MCDNSelectorOptions) -> MCDNSelector {
        let sel = MCDNSelector()
        sel._content = options
        sel.process()
        return sel
    }

    static func process(resource: Resource) -> MCDNSelector {
        let options = MCDNSelectorOptions()
        options.resource = resource
        return self.process(options: options)
    }
}

class CDNsBasedOnOverallScoresHandler: CDNsBasedOnHighScoreGroupHandler {
    override func score(_ cdn: CDN) -> Double {
        return cdn.overallScore ?? 0
    }
}

class CDNsBasedOnHighScoreGroupHandler {
    var _primeCDNs: [CDN] = []
    var _otherCDNs: [CDN] = []
    var _outcome: [CDN]?
    var threshold: Double?

    func score(_ cdn: CDN) -> Double {
        return cdn.currentScore
    }

    func process() -> [CDN] {
        self._intakeThreshold()
        self._intakeCDNs()
        self._intakeResult()
        _ = self._injectOthers()
        self._intakeOutcome()
        return self._outcome!
    }

    func _intakeThreshold() {
        var maxScore: Double = 0
        let cdns = MCDNStatsHolder.cdns.values
        for cdn in cdns {
            if self.score(cdn) > maxScore {
                maxScore = self.score(cdn)
            }
        }
        self.threshold = maxScore - MCDNConstant.MAX_ACCEPTABLE_SCORE_DIFFERENCE
    }

    func _intakeCDNs() {
        let cdns = MCDNStatsHolder.cdns.values
        let minAcceptableScore = self.threshold ?? 0
        self._primeCDNs = []
        self._otherCDNs = []
        for cdn in cdns {
            if !(cdn.isEnabled ?? false) {
                continue
            }
            if cdn.currentScore >= minAcceptableScore {
                self._primeCDNs.append(cdn)
            } else {
                self._otherCDNs.append(cdn)
            }
        }
    }

    func _intakeResult() {
        let result = RandomlySelectCDNsHandler.process(
            cdns: self._primeCDNs,
            cdnScoreGetter: { (cdn: CDN) -> Double in self.score(cdn) }
        )
        self._outcome = result
    }

    func _injectOthers() -> [CDN] {
        guard var result = _outcome else {
            return []
        }
        let others = RandomlySelectCDNsHandler.process(
            cdns: self._otherCDNs,
            cdnScoreGetter: { (cdn: CDN) -> Double in self.score(cdn) }
        )
        result += others
        return result
    }

    func _intakeOutcome() {}

    static func process() -> [CDN] {
        return CDNsBasedOnHighScoreGroupHandler().process()
    }
}

class RandomlySelectCDNsHandlerContent {
    var cdns: [CDN]?
    var cdnScoreGetter: ((CDN) -> Double?)?
}

enum RandomlySelectCDNsHandler {
    static func process(cdns: [CDN], cdnScoreGetter: (CDN) -> Double) -> [CDN] {
        return cdns.shuffled()
    }
}

class MCDNSelectorContent {
    var resource: Resource?
}

class MCDNSelectorOptions: MCDNSelectorContent {}

class CDN: Codable {
    var id: String?
    var name: String?
    var isEnabled: Bool?
    var meanBandwidth: Double = 0
    var meanAvailability: Double = 1
    var overallScore: Double?
    var currentScore: Double = 1
    var businessScore: Double?
    var type: String?
    var domain: String?
}

enum MCDNStatsHolder {
    static var instance: MCDNStats?

    static var cdns: [String: CDN] = [:]

    static var algorithmID: String? {
        get {
            return self.instance!.algorithmID
        }
        set {
            self.instance!.algorithmID = newValue
        }
    }

    static var algorithmVersion: String? {
        set {
            self.instance!.algorithmVersion = newValue
        }
        get {
            return self.instance!.algorithmVersion
        }
    }

    static var networkBandwidth: Double {
        get {
            return self.instance!.networkBandwidth
        }
        set {
            self.instance!.networkBandwidth = newValue
        }
    }
}

class CDNSource: CDN {}

class MCDNStats: Codable {
    var cdns: [String: CDN]?
    var algorithmID: String?
    var algorithmVersion: String?
    var networkBandwidth: Double = MCDNConstant.QUALIFIED_DOWNLOAD_BANDWIDTH

    func reset() {
        self.cdns = nil
        self.algorithmID = nil
        self.algorithmVersion = nil
        self.networkBandwidth = MCDNConstant.QUALIFIED_DOWNLOAD_BANDWIDTH
    }
}
