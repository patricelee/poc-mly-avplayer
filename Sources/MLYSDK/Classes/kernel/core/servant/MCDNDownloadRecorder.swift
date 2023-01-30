import Foundation

class MCDNDownloadRecorder: AbstractFlow<MCDNDownloadRecorderContent> {
    var _cdn: CDN!

    override init(content: MCDNDownloadRecorderContent) {
        self._cdn = content.source
        super.init(content: content)
    }

    override func process() async {
        await self._intakeHTTPDownloadRecord()
        await self._forwardHTTPDownloadRecord()
        if await self._shouldUpdateCDNStats() {
            await self._intakeCDNStats()
            await self._updateCDNBandwidth()
            await self._updateCDNMeanBandwidth()
            await self._updateCDNMeanAvailability()
            await self._updateCDNCurrentScore()
            await self._forwardCDNDownloadRecord()
        }
    }

    func _shouldUpdateCDNStats() async -> Bool {
        let record = await self._require(FlowKey.RECORD) as! HTTPDownloadRecord
        return record.type == DomainType.CDN.rawValue
    }

    func _intakeHTTPDownloadRecord() async {
        let record = HTTPDownloadRecordBuilder(self._content).build()
        await self._expose(FlowKey.RECORD, record)
    }

    func _forwardHTTPDownloadRecord() async {
        let record = await self._require(FlowKey.RECORD) as! HTTPDownloadRecord
        await MetricsCollectorHolder.emit(MetricsCollectorEvent.HTTP_DOWNLOAD_RECORD, record)
    }

    func _intakeCDNStats() async {
        let record = await self._require(FlowKey.RECORD) as! HTTPDownloadRecord
        self._cdn = MCDNStatsHolder.cdns[record.id!]!
    }

    func _updateCDNBandwidth() async {
        let record = await self._require(FlowKey.RECORD) as! HTTPDownloadRecord
        guard let bandwidth = record.bandwidth else {
            return
        }
        MCDNStatsHolder.networkBandwidth = Math.max(MCDNConstant.QUALIFIED_DOWNLOAD_BANDWIDTH, (MCDNStatsHolder.networkBandwidth + bandwidth) / 2)
    }

    func _updateCDNMeanBandwidth() async {
        let record = await self._require(FlowKey.RECORD) as! HTTPDownloadRecord
        if record.bandwidth == nil {
            return
        }
        await MeanBandwidthCalculator.process(
            MeanBandwidthCalculatorContent(cdn: self._cdn)
        )
    }

    func _updateCDNMeanAvailability() async {
        await MeanAvailabilityCalculator.process(
            MeanAvailabilityCalculatorContent(cdn: self._cdn)
        )
    }

    func _updateCDNCurrentScore() async {
        await CurrentScoreCalculator.process(
            CurrentScoreCalculatorContent(cdn: self._cdn)
        )
    }

    func _forwardCDNDownloadRecord() async {
        await MetricsCollectorHolder.emit(MetricsCollectorEvent.CDN_DOWNLOAD_RECORD, CDNDownloadRecord(
            ctime: Date.now(), id: self._cdn.id, name: self._cdn.name, type: self._cdn.type, domain: self._cdn.domain, meanBandwidth: self._cdn.meanBandwidth, meanAvailability: self._cdn.meanAvailability, currentScore: self._cdn.currentScore
        ))
    }

    static func process(_ options: MCDNDownloadRecorderOptions) async {
        await MCDNDownloadRecorder(
            content: options
        ).process()
    }
}

typealias MCDNDownloadRecorderContent = HTTPDownloadRecordBuilderOptions
typealias MCDNDownloadRecorderOptions = MCDNDownloadRecorderContent
class HTTPDownloadRecordBuilder {
    var _content: HTTPDownloadRecord!
    var _options: HTTPDownloadRecordBuilderOptions!

    init(_ _options: HTTPDownloadRecordBuilderOptions) {
        self._options = _options
        self._initialize()
    }

    func build() -> HTTPDownloadRecord {
        return self._content!
    }

    func _initialize() {
        self._setContent()
        self._setContentSize()
        self._setElapsedTime()
        self._setIsOutlier()
        self._setBandwidth()
    }

    func _setContent() {
        let options = self._options!
        self._content = HTTPDownloadRecord(
            ctime: Date.now(),
            id: options.source?.id,
            name: options.source?.name,
            type: options.source?.type,
            domain: options.source?.domain,
            totalSize: options.resource?.total,
            contentType: options.resource?.type,
            startTime: options.startTime,
            isAborted: options.aborter?.task?.isAborted,
            isSuccess: options.error == nil,
            isComplete: options.resource?.isComplete,
            swarmID: options.resource?.swarmID,
            swarmURI: options.resource?.swarmURI,
            sourceURI: options.resource?.sourceURI,
            requestURI: options.requestURI,
            responseCode: options.payload?.state,
            errorMessage: options.error?.localizedDescription,
            algorithmID: MCDNStatsHolder.algorithmID,
            algorithmVersion: MCDNStatsHolder.algorithmVersion
        )
    }

    func _setContentSize() {
        let options = self._options!
        self._content.contentSize = options.resource!.size - options.startSize!
    }

    func _setElapsedTime() {
        let measurement = self._options!.measurement!
        if self._content!.isSuccess! {
            return
        }
        self._content!.elapsedTime = measurement.elapsedTimeS()
    }

    func _setIsOutlier() {
        self._content.isOutlier = Int(self._content.contentSize!) < MCDNConstant.MIN_SIZE_FOR_BANDWIDTH_MEASUREMENT
    }

    func _setBandwidth() {
        if self._content.isSuccess! || self._content.isOutlier! {
            return
        }
        self._content.bandwidth = Double(self._content.contentSize!) / self._content.elapsedTime!
    }
}

struct HTTPDownloadRecordBuilderOptions {
    var source: CDN?
    var resource: Resource?
    var payload: SpecTask?
    var error: Error?
    var aborter: AbortController?
    var requestURI: String?
    var startSize: Int?
    var startTime: TimeInterval?
    var measurement: PerformanceResourceTiming?
    init(source: CDN? = nil, resource: Resource? = nil, payload: SpecTask? = nil, error: Error? = nil, aborter: AbortController? = nil, requestURI: String? = nil, startSize: Int? = nil, startTime: TimeInterval? = nil, measurement: PerformanceResourceTiming? = .init()) {
        self.source = source
        self.resource = resource
        self.payload = payload
        self.error = error
        self.aborter = aborter
        self.requestURI = requestURI
        self.startSize = startSize
        self.startTime = startTime
        self.measurement = measurement
    }
}

class MeanBandwidthCalculator: AbstractFlow<MeanBandwidthCalculatorContent> {
    var _cdn: CDN!
    var options: MeanBandwidthCalculatorContent!
    init(_ options: MeanBandwidthCalculatorContent) {
        super.init(content: options)
        self.options = options
        self._cdn = options.cdn
    }

    override func process() async {
        await self._intakeResult()
        await self._updateCDN()
    }

    func _intakeResult() async {
        let metrics = MetricsStatsHolder.cdns[self._cdn!.id!]!
        let dataset = metrics.download!.bandwidth.dataset
        var baseline = Date.now() - MetricsConstant.DURATION_OF_RETAINED_DATA
        if dataset.count > 0 {
            baseline = Math.min(dataset[0].ctime!, baseline)
        }
        let result = MathCalculator.weightedAverage(dataset.map { data in
            WeightedData(offset: data.ctime! - baseline, value: data.value!)
        }
        )
        await self._expose(FlowKey.RESULT, result)
    }

    func _updateCDN() async {
        let result = await self._require(FlowKey.RESULT) as! Double
        self._cdn.meanBandwidth = result
    }

    static func process(_ options: MeanBandwidthCalculatorContent) async {
        await MeanBandwidthCalculator(
            options
        ).process()
    }
}

struct MeanBandwidthCalculatorContent {
    var cdn: CDN
    init(cdn: CDN) {
        self.cdn = cdn
    }
}

class MeanAvailabilityCalculator: AbstractFlow<MeanAvailabilityCalculatorContent> {
    var _cdn: CDN!
    override init(content: MeanAvailabilityCalculatorContent) {
        self._cdn = content.cdn
        super.init(content: content)
    }

    override func process() async {
        await self._intakeResult()
        await self._updateCDN()
    }

    func _intakeResult() async {
        guard let metrics = MetricsStatsHolder.cdns[self._cdn.id!] else {
            return
        }
        let dataset = metrics.download!.outcome.dataset
        var baseline = Date.now() - MetricsConstant.DURATION_OF_RETAINED_DATA
        if dataset.count > 0 {
            baseline = Math.min(dataset[0].ctime!, baseline)
        }
        let result = MathCalculator.weightedAverage(dataset.map { data in
            WeightedData(offset: data.ctime! - baseline, value: data.value!)
        }
        )
        await self._expose(FlowKey.RESULT, result)
    }

    func _updateCDN() async {
        guard let result = await self._require(FlowKey.RESULT) as? Double else {
            return
        }
        self._cdn.meanAvailability = result
    }

    static func process(_ content: MeanAvailabilityCalculatorContent) async {
        await MeanAvailabilityCalculator(
            content: content
        ).process()
    }
}

struct MeanAvailabilityCalculatorContent {
    var cdn: CDN
    init(cdn: CDN) {
        self.cdn = cdn
    }
}

class CurrentScoreCalculator: AbstractFlow<CurrentScoreCalculatorContent> {
    var _cdn: CDN
    var _scoreParts: FeedbackScoreParts

    override init(content: CurrentScoreCalculatorContent) {
        self._cdn = content.cdn
        self._scoreParts = FeedbackScoreParts()
        super.init(content: content)
    }

    override func process() async {
        await self._scoreBandwidth()
        await self._scoreAvailability()
        await self._updateCDN()
    }

    func _scoreBandwidth() async {
        let bandwidthScore = self._cdn.meanBandwidth / MCDNStatsHolder.networkBandwidth
        self._scoreParts.bandwidth = Math.min(bandwidthScore, 1.0)
    }

    func _scoreAvailability() async {
        let availabilityScore = pow(self._cdn.meanAvailability, MCDNConstant.PENALTY_POWER_OF_AVAILABILITY)
        self._scoreParts.availability = availabilityScore
    }

    func _updateCDN() async {
        let currentScore = self._cdn.currentScore
        let feedbackScore = self._scoreParts.bandwidth * self._scoreParts.availability
        self._cdn.currentScore = (currentScore + feedbackScore) / 2
    }

    static func process(_ options: CurrentScoreCalculatorContent) async {
        await CurrentScoreCalculator(
            content: options
        ).process()
    }
}

struct CurrentScoreCalculatorContent {
    var cdn: CDN
    init(cdn: CDN) {
        self.cdn = cdn
    }
}

struct FeedbackScoreParts {
    var bandwidth: Double!
    var availability: Double!
}
