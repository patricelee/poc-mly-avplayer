

class MetricsExporter: Emittery {
    func emit(eventName: String, eventData: Any) async {
        await super.emit(eventName, eventData)
    }
}

class MetricsExporterEvent {
    static var HTTP_DOWNLOAD_RECORD = "http_download_record"
    static var HTTP_DOWNLOAD_PULSE_TRAFFIC = "http_download_pulse_traffic"
    static var HTTP_DOWNLOAD_CUMULATIVE_TRAFFIC = "http_download_cumulative_traffic"
    static var HTTP_DOWNLOAD_WMA_BANDWIDTH = "http_download_wma_bandwidth"
    static var HTTP_DOWNLOAD_USAGE_PULSE_COUNT = "http_download_usage_pulse_count"
    static var HTTP_DOWNLOAD_USAGE_CUMULATIVE_COUNT = "http_download_usage_cumulative_count"
    static var HTTP_DOWNLOAD_SUCCESS_PULSE_COUNT = "http_download_success_pulse_count"
    static var HTTP_DOWNLOAD_SUCCESS_CUMULATIVE_COUNT = "http_download_success_cumulative_count"
    static var HTTP_DOWNLOAD_FAILURE_PULSE_COUNT = "http_download_failure_pulse_count"
    static var HTTP_DOWNLOAD_FAILURE_CUMULATIVE_COUNT = "http_download_failure_cumulative_count"
    static var CDN_DOWNLOAD_LAST_MEAN_BANDWIDTH = "cdn_download_last_mean_bandwidth"
    static var CDN_DOWNLOAD_LAST_MEAN_AVAILABILITY = "cdn_download_last_mean_availability"
    static var CDN_DOWNLOAD_LAST_CURRENT_SCORE = "cdn_download_last_current_score"
    static var P2P_DOWNLOAD_RECORD = "p2p_download_record"
    static var P2SP_SYSTEM_STATE = "p2sp_system_state"
    static var SOURCE_PULSE_TRAFFIC = "source_pulse_traffic"
    static var SOURCE_CUMULATIVE_TRAFFIC = "source_cumulative_traffic"
}

class MetricsExporterHolder {
    static var _instance = MetricsExporter()
    static func instance() -> MetricsExporter {
        return Self._instance
    }

    static func isListened(_ eventName: String) -> Bool {
        return Self._instance.listenerCount(eventName) > 0
    }

    static func emit(_ eventName: String, _ eventData: Any) async {
        Self._instance.emit(eventName, eventData)
    }
}

class ExportHTTPDownloadRecordHandler: AbstractFlow<HTTPDownloadRecord> {
    override func process() async {
        if self._shouldExport() {
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_RECORD)
    }

    func _exportResult() async {
        let result = self._content
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_RECORD, result)
    }

    static func process(_ options: HTTPDownloadRecord) async {
        _ = await ExportHTTPDownloadRecordHandler(
            content: options
        ).process()
    }
}

struct ExportHTTPDownloadRecordContent {
    var record: HTTPDownloadRecordExport
}

typealias ExportHTTPDownloadRecordOptions = ExportHTTPDownloadRecordContent
class ExportHTTPDownloadPulseTrafficHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_PULSE_TRAFFIC)
    }

    func _intakeResult() async {
        let result = MetricsStatsHolder.cdns.data.values.map { cdn in
            HTTPDownloadPulseTrafficExport(
                id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.traffic.pulse.dataset
            )
        }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadPulseTrafficExport]
        let origin = MetricsStatsHolder.origin
        result.append(
            HTTPDownloadPulseTrafficExport(
                type: origin.type, dataset: origin.download!.traffic.pulse.dataset
            )
        )
    }

    func _exportResult() async {
        let result = await self._require(FlowKey.RESULT) as! [HTTPDownloadPulseTrafficExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_PULSE_TRAFFIC, result)
    }

    static func process() async {
        await ExportHTTPDownloadPulseTrafficHandler(content: Void()).process()
    }
}

class ExportHTTPDownloadCumulativeTrafficHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_CUMULATIVE_TRAFFIC)
    }

    func _intakeResult() async {
        var result = MetricsStatsHolder.cdns.data.values.map { cdn in
            HTTPDownloadCumulativeTrafficExport(
                id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.traffic.cumulation.dataset
            )
        }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadCumulativeTrafficExport]
        let origin = MetricsStatsHolder.origin
        result.append(HTTPDownloadCumulativeTrafficExport(
            type: origin.type, dataset: origin.download!.traffic.cumulation.dataset
        )
        )
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadCumulativeTrafficExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_CUMULATIVE_TRAFFIC, result)
    }

    static func process() async {
        await ExportHTTPDownloadCumulativeTrafficHandler(content: Void()).process()
    }
}

class ExportHTTPDownloadWMABandwidthHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_WMA_BANDWIDTH)
    }

    func _intakeResult() async {
        var result = MetricsStatsHolder.cdns.data.values.map { cdn in
            HTTPDownloadWMABandwidthExport(
                id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.bandwidth.wma.dataset
            )
        }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadWMABandwidthExport]
        let origin = MetricsStatsHolder.origin
        result.append(HTTPDownloadWMABandwidthExport(
            type: origin.type, dataset: origin.download!.bandwidth.wma.dataset
        )
        )
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadWMABandwidthExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_WMA_BANDWIDTH, result)
    }

    static func process() async {
        await ExportHTTPDownloadWMABandwidthHandler(content: Void()).process()
    }
}

class ExportHTTPDownloadUsagePulseCountHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_USAGE_PULSE_COUNT)
    }

    func _intakeResult() async {
        let result = MetricsStatsHolder.cdns.data.values.map { cdn in HTTPDownloadUsagePulseCountExport(
            id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.count.usage.pulse.dataset
        ) }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadUsagePulseCountExport]
        let origin = MetricsStatsHolder.origin
        result.append(HTTPDownloadUsagePulseCountExport(type: origin.type, dataset: origin.download!.count.usage.pulse.dataset)
        )
    }

    func _exportResult() async {
        let result = await self._require(FlowKey.RESULT) as! [HTTPDownloadUsagePulseCountExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_USAGE_PULSE_COUNT, result)
    }

    static func process() async {
        await ExportHTTPDownloadUsagePulseCountHandler(content: Void()).process()
    }
}

class ExportHTTPDownloadUsageCumulativeCountHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_USAGE_CUMULATIVE_COUNT)
    }

    func _intakeResult() async {
        var result = MetricsStatsHolder.cdns.data.values.map { cdn in HTTPDownloadUsageCumulativeCountExport(
            id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.count.usage.cumulation.dataset
        ) }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadUsageCumulativeCountExport]
        let origin = MetricsStatsHolder.origin
        result.append(HTTPDownloadUsageCumulativeCountExport(
            type: origin.type, dataset: origin.download!.count.usage.cumulation.dataset
        )
        )
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadUsageCumulativeCountExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_USAGE_CUMULATIVE_COUNT, result)
    }

    static func process() async {
        await ExportHTTPDownloadUsageCumulativeCountHandler(content: Void()).process()
    }
}

class ExportHTTPDownloadSuccessPulseCountHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_SUCCESS_PULSE_COUNT)
    }

    func _intakeResult() async {
        var result = MetricsStatsHolder.cdns.data.values.map { cdn in HTTPDownloadSuccessPulseCountExport(
            id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.count.success.pulse.dataset
        ) }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadSuccessPulseCountExport]
        let origin = MetricsStatsHolder.origin
        result.append(HTTPDownloadSuccessPulseCountExport(
            type: origin.type, dataset: origin.download!.count.success.pulse.dataset
        )
        )
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadSuccessPulseCountExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_SUCCESS_PULSE_COUNT, result)
    }

    static func process() async {
        await ExportHTTPDownloadSuccessPulseCountHandler(content: Void()).process()
    }
}

class ExportHTTPDownloadSuccessCumulativeCountHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_SUCCESS_CUMULATIVE_COUNT)
    }

    func _intakeResult() async {
        var result = MetricsStatsHolder.cdns.data.values.map { cdn in HTTPDownloadSuccessCumulativeCountExport(
            id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.count.success.cumulation.dataset
        ) }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadSuccessCumulativeCountExport]
        let origin = MetricsStatsHolder.origin
        result.append(HTTPDownloadSuccessCumulativeCountExport(
            type: origin.type, dataset: origin.download!.count.success.cumulation.dataset
        )
        )
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadSuccessCumulativeCountExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_SUCCESS_CUMULATIVE_COUNT, result)
    }

    static func process() async {
        await ExportHTTPDownloadSuccessCumulativeCountHandler(content: Void()).process()
    }
}

class ExportHTTPDownloadFailurePulseCountHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_FAILURE_PULSE_COUNT)
    }

    func _intakeResult() async {
        var result = MetricsStatsHolder.cdns.data.values.map { cdn in HTTPDownloadFailurePulseCountExport(
            id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.count.failure.pulse.dataset
        ) }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadFailurePulseCountExport]
        let origin = MetricsStatsHolder.origin
        result.append(HTTPDownloadFailurePulseCountExport(
            type: origin.type, dataset: origin.download!.count.failure.pulse.dataset
        )
        )
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadFailurePulseCountExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_FAILURE_PULSE_COUNT, result)
    }

    static func process() async {
        await ExportHTTPDownloadFailurePulseCountHandler(content: Void()).process()
    }
}

class ExportHTTPDownloadFailureCumulativeCountHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._injectOrigin()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.HTTP_DOWNLOAD_FAILURE_CUMULATIVE_COUNT)
    }

    func _intakeResult() async {
        var result = MetricsStatsHolder.cdns.data.values.map { cdn in HTTPDownloadFailureCumulativeCountExport(
            id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.download!.count.failure.cumulation.dataset
        ) }
        await self._expose(FlowKey.RESULT, result)
    }

    func _injectOrigin() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadFailureCumulativeCountExport]
        let origin = MetricsStatsHolder.origin
        result.append(HTTPDownloadFailureCumulativeCountExport(
            type: origin.type, dataset: origin.download!.count.failure.cumulation.dataset
        )
        )
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! [HTTPDownloadFailureCumulativeCountExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.HTTP_DOWNLOAD_FAILURE_CUMULATIVE_COUNT, result)
    }

    static func process() async {
        await ExportHTTPDownloadFailureCumulativeCountHandler(content: Void()).process()
    }
}

class ExportCDNDownloadLastMeanBandwidthHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.CDN_DOWNLOAD_LAST_MEAN_BANDWIDTH)
    }

    func _intakeResult() async {
        var result = MetricsStatsHolder.cdns.data.values.map { cdn in CDNDownloadLastMeanBandwidthExport(
            id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.cdndownload!.meanBandwidth.last.dataset
        ) }
        await self._expose(FlowKey.RESULT, result)
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! [CDNDownloadLastMeanBandwidthExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.CDN_DOWNLOAD_LAST_MEAN_BANDWIDTH, result)
    }

    static func process() async {
        await ExportCDNDownloadLastMeanBandwidthHandler(content: Void()).process()
    }
}

class ExportCDNDownloadLastMeanAvailabilityHandler: AbstractFlow<Void> {
    override func process() async{
        if self._shouldExport() {
            await self._intakeResult()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.CDN_DOWNLOAD_LAST_MEAN_AVAILABILITY)
    }

    func _intakeResult() async {
        let result = MetricsStatsHolder.cdns.data.values.map { cdn in
            CDNDownloadLastMeanAvailabilityExport(id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.cdndownload!.meanAvailability.last.dataset)
        }
        await self._expose(FlowKey.RESULT, result)
    }

    func _exportResult() async {
        let result = await self._require(FlowKey.RESULT) as! [CDNDownloadLastMeanAvailabilityExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.CDN_DOWNLOAD_LAST_MEAN_AVAILABILITY, result)
    }

}

class ExportCDNDownloadLastCurrentScoreHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.CDN_DOWNLOAD_LAST_CURRENT_SCORE)
    }

    func _intakeResult() async {
        let result = MetricsStatsHolder.cdns.data.values.map { cdn in
            CDNDownloadLastCurrentScoreExport(
                id: cdn.id, name: cdn.name, type: cdn.type, domain: cdn.domain, isEnabled: cdn.isEnabled, dataset: cdn.cdndownload!.currentScore.last.dataset
            )
        }

        await self._expose(FlowKey.RESULT, result)
    }

    func _exportResult() async {
        let result = await self._require(FlowKey.RESULT) as! [CDNDownloadLastCurrentScoreExport]
        await MetricsExporterHolder.emit(MetricsExporterEvent.CDN_DOWNLOAD_LAST_CURRENT_SCORE, result)
    }

    static func process() async {
        _ = await ExportCDNDownloadLastCurrentScoreHandler(content: Void()).process()
    }
}

class ExportP2PDownloadRecordHandler: AbstractFlow<ExportP2PDownloadRecordContent> {
    override func process() async {
        if self._shouldExport() {
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.P2P_DOWNLOAD_RECORD)
    }

    func _exportResult() async {
        var result = self._content.record
        await MetricsExporterHolder.emit(MetricsExporterEvent.P2P_DOWNLOAD_RECORD, result)
    }

    static func process(options: ExportP2PDownloadRecordOptions) async {
        await ExportP2PDownloadRecordHandler(
            content: options

        ).process()
    }
}

struct ExportP2PDownloadRecordContent {
    var record: P2PDownloadRecordExport
}

typealias ExportP2PDownloadRecordOptions = ExportP2PDownloadRecordContent
class ExportP2SPSystemStateHandler: AbstractFlow<Void> {
    override func process() async {
        if self._shouldExport() {
            await self._intakeResult()
            await self._exportResult()
        }
    }

    func _shouldExport() -> Bool {
        return MetricsExporterHolder.isListened(MetricsExporterEvent.P2SP_SYSTEM_STATE)
    }

    func _intakeResult() async {
        let tracker = MetricsStatsHolder.tracker
        let node = MetricsStatsHolder.node
        let swarms = MetricsStatsHolder.swarms
        var result = P2SPSystemStateExport(
            tracker: tracker, node: node, swarms: swarms
        )
        await self._expose(FlowKey.RESULT, result)
    }

    func _exportResult() async {
        var result = await self._require(FlowKey.RESULT) as! P2SPSystemStateExport
        await MetricsExporterHolder.emit(MetricsExporterEvent.P2SP_SYSTEM_STATE, result)
    }

    static func process() async {
        await ExportP2SPSystemStateHandler(content: ()).process()
    }
}
