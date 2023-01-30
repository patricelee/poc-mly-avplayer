
protocol SpecCursorsTimeSeriesDataData {
    var cursors: [String: TimeSeriesDataData<Double>] { get set }
}

struct CursorsTimeSeriesDataData: SpecCursorsTimeSeriesDataData {
    var cursors: [String: TimeSeriesDataData<Double>] = [:]
}

struct TimeSeriesDataData<T: Codable>: Codable {
    var data: TimeSeriesData<T>?
    var value: T?
    init(data: TimeSeriesData<T>? = nil, value: T? = nil) {
        self.data = data
        self.value = value
    }
}

class BaseMetricsHandler<T: SpecCursorsTimeSeriesDataData>: AbstractFlow<T> {
    override func process() async {
        await self._iterateMetrics {
            await self._ensureCursor()
            await self._intakeIndex()
            await self._intakeData()
            await self._updateMetrics()
        }
        await self._exportMetrics()
    }

    func _iterateMetrics(_ callback: () async -> ()) async {
        var metricsList: [Any] = []
        MetricsStatsHolder.cdns.data.values.forEach { metricsList.append($0) }
        metricsList.append(MetricsStatsHolder.origin)

        for metrics in metricsList {
            await self._expose(FlowKey.METRICS, metrics)
            await callback()
        }
        await self._remove(FlowKey.METRICS, FlowKey.INDEX, FlowKey.DATA)
    }

    func _ensureCursor() async {
        let metrics = await self._require(FlowKey.METRICS) as! DomainMetrics
        self._content.cursors[metrics.id!] = TimeSeriesDataData<Double>()
    }

    func _intakeIndex() async {
        let metrics = await self._require(FlowKey.METRICS) as! DomainMetrics
        let cursor = self._content.cursors[metrics.id!]!
        let (from, _) = self._dataset(metrics.download!)
        let index = from?.dataset.lastIndex(where: { $0 == cursor.data! })
        await self._expose(FlowKey.INDEX, index)
    }

    func _intakeData() async {
        let metrics = await self._require(FlowKey.METRICS) as! DomainMetrics
        let index = await self._require(FlowKey.INDEX) as! Int
        let dataset = metrics.download!.traffic.dataset
        var value = 0.0
        for i in index ..< dataset.count {
            value += dataset[i].value!
        }
        let data = TimeSeriesData(value)
        await self._expose(FlowKey.DATA, data)
    }

    func _updateMetrics() async {
        let metrics = await self._require(FlowKey.METRICS) as! DomainMetrics
        let data = await self._require(FlowKey.DATA) as! TimeSeriesData<Double>
        let (from, to) = self._dataset(metrics.download!)
        to?.dataset.append(data)
        self._content.cursors[metrics.id!] = TimeSeriesDataData(data: from?.dataset.last)
    }

    func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        Logger.error("_dataset didnot implemented")
        return (nil, nil)
    }

    func _exportMetrics() async {
        Logger.error("_exportMetrics didnot implemented")
    }
}

class HTTPDownloadRecordDuty: TaskState {}

class HTTPDownloadRecordHandler: Flow {
    
    override func process() async -> Any? {
        await self._intakeRecord()
        await self._intakeMetrics()
        await self._updateMetrics()
        await self._exportMetrics()
        return true
    }

    func _intakeRecord() async {
        let record = await MetricsCollector.instance?._recordHub.extract(MetricsCollectorEvent.HTTP_DOWNLOAD_RECORD)
        await self._expose(FlowKey.RECORD, record)
    }

    func _intakeMetrics() async {
        let record = await self._require(FlowKey.RECORD) as! HTTPDownloadRecord
        var metrics: Any
        if record.id == nil {
            metrics = MetricsStatsHolder.origin
        } else {
            metrics = MetricsStatsHolder.cdns[record.id!]!
        }
        await self._expose(FlowKey.METRICS, metrics)
    }

    func _updateMetrics() async {
        let record = await self._require(FlowKey.RECORD) as! HTTPDownloadRecord
        let metrics = await self._require(FlowKey.METRICS) as! DomainMetrics
        metrics.download!.count.usage.dataset.append(TimeSeriesData(1, ctime: record.ctime))
        var value: Double = 1
        if record.isSuccess! {
            metrics.download!.count.success.dataset.append(TimeSeriesData(1, ctime: record.ctime))
        }
        else {
            value = 0
            metrics.download!.count.failure.dataset.append(TimeSeriesData(1, ctime: record.ctime))
        }
        metrics.download!.outcome.dataset.append(TimeSeriesData(value, ctime: record.ctime))
        metrics.download!.traffic.dataset.append(
            TimeSeriesData(Double(record.contentSize!), ctime: record.ctime)
        )
        if record.bandwidth != nil {
            metrics.download!.bandwidth.dataset.append(
                TimeSeriesData(record.bandwidth, ctime: record.ctime)
            )
        }
        MetricsStatsHolder.source.http_download_records.append(record)
    }

    func _exportMetrics() async {
        let record = await self._require(FlowKey.RECORD) as! HTTPDownloadRecord
        await ExportHTTPDownloadRecordHandler.process(record)
    }
}

struct HTTPDownloadPulseTrafficDutyContent {
    var cursors: [String: TimeSeriesDataData<Double>] = [:]
}

class HTTPDownloadPulseTrafficHandler: AbstractFlow<()> {
    func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        return (download.traffic, download.traffic.pulse)
    }

    func _exportMetrics() async {
        await ExportHTTPDownloadPulseTrafficHandler.process()
    }
}

typealias HTTPDownloadCumulativeTrafficHandlerContent = CursorsTimeSeriesDataData
typealias HTTPDownloadCumulativeTrafficHandlerOptions = HTTPDownloadCumulativeTrafficHandlerContent

typealias HTTPDownloadPulseTrafficHandlerContent = HTTPDownloadPulseTrafficDutyContent
typealias HTTPDownloadPulseTrafficHandlerOptions = HTTPDownloadPulseTrafficHandlerContent
class HTTPDownloadCumulativeTrafficHandler: BaseMetricsHandler<HTTPDownloadCumulativeTrafficHandlerOptions> {
    override func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        return (download.traffic, download.traffic.cumulation)
    }

    override func _exportMetrics() async {
        await ExportHTTPDownloadCumulativeTrafficHandler.process()
    }
}

class HTTPDownloadWMABandwidthHandler: AbstractFlow<HTTPDownloadWMABandwidthHandlerOptions> {
    override func process() async {
        await self._iterateMetrics({
            await self._intakeData()
            await self._updateMetrics()
        }
        )
        await self._exportMetrics()
    }

    func _iterateMetrics(_ callback: () async -> ()) async {
        var metricsList: [Any] = []
        MetricsStatsHolder.cdns.data.values.forEach { metricsList.append($0) }
        metricsList.append(MetricsStatsHolder.origin)
        for metrics in metricsList {
            await self._expose(FlowKey.METRICS, metrics)
            await callback()
        }
        await self._remove(FlowKey.METRICS, FlowKey.INDEX, FlowKey.DATA)
    }

    func _intakeData() async {
        let metrics = await self._require(FlowKey.METRICS) as! DomainMetrics
        let now = Date.now()
        let baseline = now - MetricsConstant.DURATION_OF_WMA_DATA*1
        let dataset = metrics.download!.bandwidth.dataset.filter { data in data.ctime! >= baseline }
        let value: Double = MathCalculator.weightedAverage(dataset.map { data in
            WeightedData(offset: data.ctime! - baseline, value: data.value!)
        }
        )
        let data = TimeSeriesData(value)
        await self._expose(FlowKey.DATA, data)
    }

    func _updateMetrics() async {
        let metrics = await self._require(FlowKey.METRICS) as! DomainMetrics
        let data = await self._require(FlowKey.DATA) as! TimeSeriesData<Double>
        metrics.download!.bandwidth.wma.dataset.append(data)
    }

    func _exportMetrics() async {
        await ExportHTTPDownloadWMABandwidthHandler.process()
    }

    static func process(_ options: HTTPDownloadWMABandwidthHandlerOptions) async {
        await HTTPDownloadWMABandwidthHandler(
            content: options
        ).process()
    }
}

typealias HTTPDownloadWMABandwidthDutyContent = CursorsTimeSeriesDataData

typealias HTTPDownloadWMABandwidthHandlerContent = HTTPDownloadWMABandwidthDutyContent
typealias HTTPDownloadWMABandwidthHandlerOptions = HTTPDownloadWMABandwidthHandlerContent

typealias HTTPDownloadUsagePulseCountHandlerContent = CursorsTimeSeriesDataData
typealias HTTPDownloadUsagePulseCountHandlerOptions = HTTPDownloadUsagePulseCountHandlerContent

class HTTPDownloadUsagePulseCountHandler: BaseMetricsHandler<HTTPDownloadUsagePulseCountHandlerOptions> {
    override func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        if download is CDNMetricsDownload {
            return (download.count.usage, download.count.usage.pulse)
        }
        return (nil, nil)
    }

    override func _exportMetrics() async {
        await ExportHTTPDownloadUsagePulseCountHandler.process()
    }
}

typealias HTTPDownloadUsageCumulativeCountHandlerContent = CursorsTimeSeriesDataData
typealias HTTPDownloadUsageCumulativeCountHandlerOptions = HTTPDownloadUsageCumulativeCountHandlerContent

class HTTPDownloadUsageCumulativeCountHandler: BaseMetricsHandler<HTTPDownloadUsageCumulativeCountHandlerOptions> {
    override func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        if download is CDNMetricsDownload {
            return (download.count.usage, download.count.usage.cumulation)
        }
        return (nil, nil)
    }

    override func _exportMetrics() async {
        await ExportHTTPDownloadUsageCumulativeCountHandler.process()
    }
}

typealias HTTPDownloadSuccessPulseCountHandlerContent = CursorsTimeSeriesDataData
typealias HTTPDownloadSuccessPulseCountHandlerOptions = HTTPDownloadSuccessPulseCountHandlerContent
class HTTPDownloadSuccessPulseCountHandler: BaseMetricsHandler<HTTPDownloadSuccessPulseCountHandlerOptions> {
    override func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        return (download.count.success, download.count.success.pulse)
    }

    override func _exportMetrics() async {
        await ExportHTTPDownloadSuccessPulseCountHandler.process()
    }
}

class HTTPDownloadSuccessCumulativeCountHandler: BaseMetricsHandler<CursorsTimeSeriesDataData> {
    override func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        if download is CDNMetricsDownload {
            return (download.count.success, download.count.success.cumulation)
        }
        return (nil, nil)
    }

    override func _exportMetrics() async {
        await ExportHTTPDownloadSuccessCumulativeCountHandler.process()
    }
}

class HTTPDownloadFailurePulseCountHandler: BaseMetricsHandler<CursorsTimeSeriesDataData> {
    override func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        if download is CDNMetricsDownload {
            return (download.count.failure, download.count.failure.pulse)
        }
        return (nil, nil)
    }

    override func _exportMetrics() async {
        await ExportHTTPDownloadFailurePulseCountHandler.process()
    }
}

class HTTPDownloadFailureCumulativeCountHandler: BaseMetricsHandler<CursorsTimeSeriesDataData> {
    override func _dataset(_ download: DomainMetricsDownload) -> (from: DataSet?, to: DataSet?) {
        if download is CDNMetricsDownload {
            return (download.count.failure, download.count.failure.cumulation)
        }
        return (nil, nil)
    }

    override func _exportMetrics() async {
        await ExportHTTPDownloadFailureCumulativeCountHandler.process()
    }
}

class CDNConfigRecordsHandler: AbstractFlow<()> {
    override func process() async {
        await self._intakeRecords()
        await self._iterateRecords {
            await self._updateMetrics()
        }
    }

    func _intakeRecords() async {
        let records = await MetricsCollector.instance?._recordHub.extract(MetricsCollectorEvent.CDN_CONFIG_RECORDS) as! [CDNConfigRecord]
        await self._expose(FlowKey.RECORDS, records)
    }

    func _iterateRecords(_ callback: () async -> ()) async {
        let records = await self._require(FlowKey.RECORDS) as! [CDNConfigRecord]
        for record in records {
            await self._expose(FlowKey.RECORD, record)
            await callback()
        }
        await self._remove(FlowKey.RECORD)
    }

    func _updateMetrics() async {
        let record = await self._require(FlowKey.RECORD) as! CDNConfigRecord
        MetricsStatsHolder.setupCDN(record)
    }
}

class CDNDownloadRecordHandler: AbstractFlow<()> {
    override func process() async {
        await self._intakeRecord()
        await self._updateMetrics()
    }

    func _intakeRecord() async {
        let record = await MetricsCollector.instance?._recordHub.extract(MetricsCollectorEvent.CDN_DOWNLOAD_RECORD) as! CDNDownloadRecord
        await self._expose(FlowKey.RECORD, record)
    }

    func _updateMetrics() async {
        let record = await self._require(FlowKey.RECORD) as! CDNDownloadRecord
        let metrics = MetricsStatsHolder.cdns[record.id!]!
        metrics.cdndownload!.meanBandwidth.dataset.append(TimeSeriesData(record.meanBandwidth, ctime: record.ctime))

        metrics.cdndownload!.meanAvailability.dataset.append(
            TimeSeriesData(record.meanAvailability, ctime: record.ctime)
        )
        metrics.cdndownload!.currentScore.dataset.append(
            TimeSeriesData(record.currentScore, ctime: record.ctime)
        )
    }
}

class CDNDownloadLastMeanBandwidthHandler: AbstractFlow<CursorsTimeSeriesDataData> {
    override func process() async {
        await self._iterateMetrics({
            await self._ensureCursor()
            await self._intakeData()
            await self._updateMetrics()
        }
        )
        await self._exportMetrics()
    }

    func _iterateMetrics(_ callback: () async -> ()) async {
        let metricsList = MetricsStatsHolder.cdns.data.values
        for metrics in metricsList {
            await self._expose(FlowKey.METRICS, metrics)
            await callback()
        }
        await self._remove(FlowKey.METRICS, FlowKey.INDEX, FlowKey.DATA)
    }

    func _ensureCursor() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        self._content.cursors[metrics.id!] = TimeSeriesDataData()
    }

    func _intakeData() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        let cursor = self._content.cursors[metrics.id!]!
        let dataset = metrics.cdndownload!.meanBandwidth.dataset
        let data = TimeSeriesData(cursor.value)
        await self._expose(FlowKey.DATA, data)
    }

    func _updateMetrics() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        let data = await self._require(FlowKey.DATA) as! TimeSeriesData<Double>
        let dataset = metrics.cdndownload!.meanBandwidth.dataset
        metrics.cdndownload!.meanBandwidth.last.dataset.append(data)
        self._content.cursors[metrics.id!] = TimeSeriesDataData(
            data: dataset[dataset.count - 1], value: data.value
        )
    }

    func _exportMetrics() async {
        await ExportCDNDownloadLastMeanBandwidthHandler.process()
    }
}

class CDNDownloadLastMeanAvailabilityHandler: AbstractFlow<CursorsTimeSeriesDataData> {
    override func process() async {
        await self._iterateMetrics({
            await self._ensureCursor()
            await self._intakeData()
            await self._updateMetrics()
        }
        )
        await self._exportMetrics()
    }

    func _iterateMetrics(_ callback: () async -> ()) async {
        let metricsList = MetricsStatsHolder.cdns.data.values
        for metrics in metricsList {
            await self._expose(FlowKey.METRICS, metrics)
            await callback()
        }
        await self._remove(FlowKey.METRICS, FlowKey.INDEX, FlowKey.DATA)
    }

    func _ensureCursor() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        let cursor = self._content.cursors[metrics.id!]
        if cursor != nil {
            self._content.cursors[metrics.id!] = TimeSeriesDataData(
                data: TimeSeriesData(0), value: 1.0
            )
        }
    }

    func _intakeData() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        let cursor = self._content.cursors[metrics.id!]!
        let dataset = metrics.cdndownload!.meanAvailability.dataset
        let data = TimeSeriesData<Double>(
            dataset[dataset.count - 1].value ?? cursor.value
        )
        await self._expose(FlowKey.DATA, data)
    }

    func _updateMetrics() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        let data = await self._require(FlowKey.DATA) as! TimeSeriesData<Double>
        let dataset = metrics.cdndownload!.meanAvailability.dataset
        metrics.cdndownload!.meanAvailability.last.dataset.append(data)
        self._content.cursors[metrics.id!] = TimeSeriesDataData(
            data: dataset[dataset.count - 1], value: data.value
        )
    }

    func _exportMetrics() async {
        await ExportCDNDownloadLastMeanAvailabilityHandler(content: ()).process()
    }
}

typealias CDNDownloadLastMeanAvailabilityHandlerContent = CursorsTimeSeriesDataData
typealias CDNDownloadLastMeanAvailabilityHandlerOptions = CDNDownloadLastMeanAvailabilityHandlerContent
class CDNDownloadLastCurrentScoreHandler: AbstractFlow<CDNDownloadLastMeanAvailabilityHandlerOptions> {
    override func process() async {
        await self._iterateMetrics({
            await self._ensureCursor()
            await self._intakeData()
            await self._updateMetrics()
        }
        )
        await self._exportMetrics()
    }

    func _iterateMetrics(_ callback: () async -> ()) async {
        let metricsList = MetricsStatsHolder.cdns.data.values
        for metrics in metricsList {
            await self._expose(FlowKey.METRICS, metrics)
            await callback()
        }
        await self._remove(FlowKey.METRICS, FlowKey.INDEX, FlowKey.DATA)
    }

    func _ensureCursor() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        let cursor = self._content.cursors[metrics.id!]
        if cursor != nil {
            self._content.cursors[metrics.id!] = TimeSeriesDataData(
                data: TimeSeriesData(0), value: 1
            )
        }
    }

    func _intakeData() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        let cursor = self._content.cursors[metrics.id!]!
        let dataset = metrics.cdndownload!.currentScore.dataset
        let data = TimeSeriesData(
            dataset[dataset.count - 1].value
        )
        await self._expose(FlowKey.DATA, data)
    }

    func _updateMetrics() async {
        let metrics = await self._require(FlowKey.METRICS) as! CDNMetrics
        let data = await self._require(FlowKey.DATA) as! TimeSeriesData<Double>
        let dataset = metrics.cdndownload!.currentScore.dataset
        metrics.cdndownload!.currentScore.last.dataset.append(data)
        self._content.cursors[metrics.id!] = TimeSeriesDataData(
            data: dataset.last, value: data.value
        )
    }

    func _exportMetrics() async {
        await ExportCDNDownloadLastCurrentScoreHandler.process()
    }
}

typealias PurgeCDNRecordsHandlerContent = CursorsTimeSeriesDataData
typealias PurgeCDNRecordsHandlerOptions = PurgeCDNRecordsHandlerContent
class PruneMetricsStatsHandler: AbstractFlow<PurgeCDNRecordsHandlerOptions> {
    var _pruneTime = Date.now() - MetricsConstant.DURATION_OF_RETAINED_DATA*1
    override func process() async {
        await self._updateCDNs()
        await self._updateOrigin()
        await self._updateSource()
    }

    func _updateCDNs() async {
        for metrics in MetricsStatsHolder.cdns.data.values {
            await self._pruneCDN(metrics)
            await self._pruneDomain(metrics)
        }
    }

    func _updateOrigin() async {
        let metrics = MetricsStatsHolder.origin
        await self._pruneDomain(metrics)
    }

    func _updateSource() async {
        let metrics = MetricsStatsHolder.source
        await self._pruneSource(metrics)
    }

    func _pruneCDN(_ metrics: CDNMetrics) async {
        await self._pruneDataset(metrics.cdndownload!.meanBandwidth)
        await self._pruneDataset(metrics.cdndownload!.meanBandwidth.last)
        await self._pruneDataset(metrics.cdndownload!.meanAvailability)
        await self._pruneDataset(metrics.cdndownload!.meanAvailability.last)
        await self._pruneDataset(metrics.cdndownload!.currentScore)
        await self._pruneDataset(metrics.cdndownload!.currentScore.last)
    }

    func _pruneDomain(_ metrics: DomainMetrics) async {
        await self._pruneDataset(metrics.download!.traffic)
        await self._pruneDataset(metrics.download!.traffic.pulse)
        await self._pruneDataset(metrics.download!.traffic.cumulation)
        await self._pruneDataset(metrics.download!.bandwidth)
        await self._pruneDataset(metrics.download!.bandwidth.wma)
        await self._pruneDataset(metrics.download!.count.usage)
        await self._pruneDataset(metrics.download!.count.usage.pulse)
        await self._pruneDataset(metrics.download!.count.usage.cumulation)
        await self._pruneDataset(metrics.download!.count.success)
        await self._pruneDataset(metrics.download!.count.success.pulse)
        await self._pruneDataset(metrics.download!.count.success.cumulation)
        await self._pruneDataset(metrics.download!.count.failure)
        await self._pruneDataset(metrics.download!.count.failure.pulse)
        await self._pruneDataset(metrics.download!.count.failure.cumulation)
    }

    func _pruneSource(_ metrics: SourceMetrics) async {
        metrics.http_download_records.removeAll(keepingCapacity: true)
    }

    func _pruneDataset(_ dataset: DataSet) async {
        dataset.dataset.removeAll(keepingCapacity: true)
    }
}

class MetricsCollectorHolder {
    static var _instance: MetricsCollector?

    static var instance: MetricsCollector? {
        get {
            return self._instance!
        }
        set {
            self._instance = newValue
        }
    }

    static func emit(_ eventName: String, _ eventData: Any) async {
        self._instance?.emit(eventName, eventData)
    }
}
