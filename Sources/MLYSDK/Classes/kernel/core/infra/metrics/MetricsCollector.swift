


class MetricsCollector: Emittery {
    var _taskManager = TaskManager()
    var _recordHub = ChannelHub()

    static var instance: MetricsCollector?
    
    override init() {
        super.init()
        Self.instance = self
    }

    func activate() async {
        await self._taskManager.activate()
        await self._openRecordHub()
        await self._bindEvents()
        await self._buildTasks()
    }

    func deactivate() async {
        await self._taskManager.deactivate()
        await self._recordHub.close()
        self.clearListeners()
    }

    func _openRecordHub() async {
        self._recordHub.connect(MetricsCollectorEvent.HTTP_DOWNLOAD_RECORD)
        self._recordHub.connect(MetricsCollectorEvent.CDN_CONFIG_RECORDS)
        self._recordHub.connect(MetricsCollectorEvent.CDN_DOWNLOAD_RECORD)
        self._recordHub.connect(MetricsCollectorEvent.P2P_DOWNLOAD_RECORD)
        self._recordHub.connect(MetricsCollectorEvent.TRACKER_STATE_RECORD)
        self._recordHub.connect(MetricsCollectorEvent.NODE_STATE_RECORD)
        self._recordHub.connect(MetricsCollectorEvent.SWARM_STATE_RECORD)
        self._recordHub.connect(MetricsCollectorEvent.USER_STATE_RECORD)
        self._recordHub.connect(MetricsCollectorEvent.PURGE_CDN_RECORDS)
    }

    func _bindEvents() async {
        self.on(MetricsCollectorEvent.HTTP_DOWNLOAD_RECORD) { record in
            self._recordHub.deliver(MetricsCollectorEvent.HTTP_DOWNLOAD_RECORD, record)
        }
        self.on(MetricsCollectorEvent.CDN_CONFIG_RECORDS) { records in
            self._recordHub.deliver(MetricsCollectorEvent.CDN_CONFIG_RECORDS, records)
        }
        self.on(MetricsCollectorEvent.CDN_DOWNLOAD_RECORD) { record in
            self._recordHub.deliver(MetricsCollectorEvent.CDN_DOWNLOAD_RECORD, record)
        }
        self.on(MetricsCollectorEvent.P2P_DOWNLOAD_RECORD) { record in
            self._recordHub.deliver(MetricsCollectorEvent.P2P_DOWNLOAD_RECORD, record)
        }
        self.on(MetricsCollectorEvent.TRACKER_STATE_RECORD) { record in
            self._recordHub.deliver(MetricsCollectorEvent.TRACKER_STATE_RECORD, record)
        }
        self.on(MetricsCollectorEvent.NODE_STATE_RECORD) { record in
            self._recordHub.deliver(MetricsCollectorEvent.NODE_STATE_RECORD, record)
        }
        self.on(MetricsCollectorEvent.SWARM_STATE_RECORD) { record in
            self._recordHub.deliver(MetricsCollectorEvent.SWARM_STATE_RECORD, record)
        }
        self.on(MetricsCollectorEvent.USER_STATE_RECORD) { record in
            self._recordHub.deliver(MetricsCollectorEvent.USER_STATE_RECORD, record)
        }
        self.on(MetricsCollectorEvent.PURGE_CDN_RECORDS) { record in
            self._recordHub.deliver(MetricsCollectorEvent.PURGE_CDN_RECORDS, record)
        }
    }

    // eslint-disable-next-line max-statements
    func _buildTasks() async {
        await self._buildHandleHTTPDownloadRecordTask()
        await self._buildHandleHTTPDownloadPulseTrafficTask()
        await self._buildHandleHTTPDownloadCumulativeTrafficTask()
        await self._buildHandleHTTPDownloadWMABandwidthTask()
        await self._buildHandleHTTPDownloadUsagePulseCountTask()
        await self._buildHandleHTTPDownloadUsageCumulativeCountTask()
        await self._buildHandleHTTPDownloadSuccessPulseCountTask()
        await self._buildHandleHTTPDownloadSuccessCumulativeCountTask()
        await self._buildHandleHTTPDownloadFailurePulseCountTask()
        await self._buildHandleHTTPDownloadFailureCumulativeCountTask()
        await self._buildHandleCDNConfigRecordsTask()
        await self._buildHandleCDNDownloadRecordTask()
        await self._buildHandleCDNDownloadLastMeanBandwidthTask()
        await self._buildHandleCDNDownloadLastMeanAvailabilityTask()
        await self._buildHandleCDNDownloadLastCurrentScoreTask()
        await self._buildHandleP2PDownloadRecordTask()
        await self._buildHandleTrackerStateRecordTask()
        await self._buildHandleNodeStateRecordTask()
        await self._buildHandleSwarmStateRecordTask()
        await self._buildHandleUserStateRecordTask()
        await self._buildHandlePurgeCDNRecordsTask()
        await self._buildHandlePruneMetricsStatsTask()
    }

    func _buildHandleHTTPDownloadRecordTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_RECORD,
            flow: HTTPDownloadRecordHandler(),
            sleepSeconds: 1,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadPulseTrafficTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_PULSE_TRAFFIC,
            flow: VoidFlow(HTTPDownloadPulseTrafficHandler(content: ())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadCumulativeTrafficTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_CUMULATIVE_TRAFFIC,
            flow: VoidFlow(HTTPDownloadCumulativeTrafficHandler(content: HTTPDownloadCumulativeTrafficHandlerOptions())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadWMABandwidthTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_WMA_BANDWIDTH,
            flow: VoidFlow(HTTPDownloadWMABandwidthHandler(content: HTTPDownloadWMABandwidthHandlerOptions())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadUsagePulseCountTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_USAGE_PULSE_COUNT,
            flow: VoidFlow(HTTPDownloadUsagePulseCountHandler(content: HTTPDownloadUsagePulseCountHandlerOptions())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadUsageCumulativeCountTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_USAGE_CUMULATIVE_COUNT,
            flow: VoidFlow(HTTPDownloadUsageCumulativeCountHandler(content: HTTPDownloadUsageCumulativeCountHandlerOptions())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadSuccessPulseCountTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_SUCCESS_PULSE_COUNT,
            flow: VoidFlow(HTTPDownloadSuccessPulseCountHandler(content: HTTPDownloadSuccessPulseCountHandlerOptions())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadSuccessCumulativeCountTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_SUCCESS_CUMULATIVE_COUNT,
            flow: VoidFlow(HTTPDownloadSuccessCumulativeCountHandler(content: CursorsTimeSeriesDataData())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadFailurePulseCountTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_FAILURE_PULSE_COUNT,
            flow: VoidFlow(HTTPDownloadFailurePulseCountHandler(content: CursorsTimeSeriesDataData())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleHTTPDownloadFailureCumulativeCountTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_HTTP_DOWNLOAD_FAILURE_CUMULATIVE_COUNT,
            flow: VoidFlow(HTTPDownloadFailureCumulativeCountHandler(content: CursorsTimeSeriesDataData())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleCDNConfigRecordsTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_CDN_CONFIG_RECORDS,
            flow: VoidFlow(CDNConfigRecordsHandler(content: ())),
            sleepSeconds: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleCDNDownloadRecordTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_CDN_DOWNLOAD_RECORD,
            flow: VoidFlow(CDNDownloadRecordHandler(content: ())),
            sleepSeconds: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleCDNDownloadLastMeanBandwidthTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_CDN_DOWNLOAD_LAST_MEAN_BANDWIDTH,
            flow: VoidFlow(CDNDownloadLastMeanBandwidthHandler(content: CursorsTimeSeriesDataData())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleCDNDownloadLastMeanAvailabilityTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_CDN_DOWNLOAD_LAST_MEAN_AVAILABILITY,
            flow: VoidFlow(CDNDownloadLastMeanAvailabilityHandler(content: CursorsTimeSeriesDataData())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleCDNDownloadLastCurrentScoreTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: MetricsCollectorTaskName.HANDLE_CDN_DOWNLOAD_LAST_CURRENT_SCORE,
            flow: VoidFlow(CDNDownloadLastCurrentScoreHandler(content: CDNDownloadLastMeanAvailabilityHandlerOptions())),
            sleepFirst: true,
            sleepSeconds: 3,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleP2PDownloadRecordTask() async {
//        await self._taskManager.createCyclicTask(TaskState(
//            name: MetricsCollectorTaskName.HANDLE_P2P_DOWNLOAD_RECORD,
//        flow: P2PDownloadRecordHandler(),
//            sleepSeconds: 0,
//            maxErrorRetry: -1,
//            maxTotalRetry: -1
//        ))
    }

    func _buildHandleTrackerStateRecordTask() async {
//        await self._taskManager.createCyclicTask(TaskState(
//            name: MetricsCollectorTaskName.HANDLE_TRACKER_STATE_RECORD,
//        flow: HTTPDownloadRecordFlow(),
//            sleepSeconds: 0,
//            maxErrorRetry: -1,
//            maxTotalRetry: -1
//        ))
    }

    func _buildHandleNodeStateRecordTask() async {
//        await self._taskManager.createCyclicTask(TaskState(
//            name: MetricsCollectorTaskName.HANDLE_NODE_STATE_RECORD,
//        flow: HTTPDownloadRecordFlow(),
//            sleepSeconds: 0,
//            maxErrorRetry: -1,
//            maxTotalRetry: -1
//        ))
    }

    func _buildHandleSwarmStateRecordTask() async {
//        await self._taskManager.createCyclicTask(TaskState(
//            name: MetricsCollectorTaskName.HANDLE_SWARM_STATE_RECORD,
//            flow: HTTPDownloadRecordFlow(),
//            sleepSeconds: 0,
//            maxErrorRetry: -1,
//            maxTotalRetry: -1
//        ))
    }

    func _buildHandleUserStateRecordTask() async {
//        await self._taskManager.createCyclicTask(TaskState(
//            name: MetricsCollectorTaskName.HANDLE_USER_STATE_RECORD,
//            flow: HTTPDownloadRecordFlow(),
//            sleepSeconds: 0,
//            maxErrorRetry: -1,
//            maxTotalRetry: -1
//        ))
    }

    func _buildHandlePurgeCDNRecordsTask() async {
//        await self._taskManager.createCyclicTask(TaskState(
//            name: MetricsCollectorTaskName.HANDLE_PURGE_CDN_RECORDS,
//            flow: PurgeCDNRecordsHandler(),
//            sleepSeconds: 0,
//            maxErrorRetry: -1,
//            maxTotalRetry: -1
//        ))
    }

    func _buildHandlePruneMetricsStatsTask() async {
//        await self._taskManager.createCyclicTask(TaskState(
//            name: MetricsCollectorTaskName.HANDLE_PRUNE_METRICS_STATS,
//            flow: PruneMetricsStatsHandler(),
//            sleepFirst: true,
//            sleepSeconds: 10,
//            sleepJitter: 0,
//            maxErrorRetry: -1,
//            maxTotalRetry: -1
//        ))
    }
}

class MetricsCollectorEvent {
    static let HTTP_DOWNLOAD_RECORD = "http_download_record"
    static let CDN_CONFIG_RECORDS = "cdn_config_records"
    static let CDN_DOWNLOAD_RECORD = "cdn_download_record"
    static let P2P_DOWNLOAD_RECORD = "p2p_download_record"
    static let TRACKER_STATE_RECORD = "tracker_state_record"
    static let NODE_STATE_RECORD = "node_state_record"
    static let SWARM_STATE_RECORD = "swarm_state_record"
    static let USER_STATE_RECORD = "user_state_record"
    static let PURGE_CDN_RECORDS = "purge_cdn_records"
}

class MetricsCollectorTaskName {
    static let HANDLE_HTTP_DOWNLOAD_RECORD = "metrics collector: handle http download record"
    static let HANDLE_HTTP_DOWNLOAD_PULSE_TRAFFIC = "metrics collector: handle http download pulse traffic"
    static let HANDLE_HTTP_DOWNLOAD_CUMULATIVE_TRAFFIC = "metrics collector: handle http download cumulative traffic"
    static let HANDLE_HTTP_DOWNLOAD_WMA_BANDWIDTH = "metrics collector: handle http download wma bandwidth"
    static let HANDLE_HTTP_DOWNLOAD_USAGE_PULSE_COUNT = "metrics collector: handle http download usage pulse count"
    static let HANDLE_HTTP_DOWNLOAD_USAGE_CUMULATIVE_COUNT = "metrics collector: handle http download usage cumulative count"
    static let HANDLE_HTTP_DOWNLOAD_SUCCESS_PULSE_COUNT = "metrics collector: handle http download success pulse count"
    static let HANDLE_HTTP_DOWNLOAD_SUCCESS_CUMULATIVE_COUNT = "metrics collector: handle http download success cumulative count"
    static let HANDLE_HTTP_DOWNLOAD_FAILURE_PULSE_COUNT = "metrics collector: handle http download failure pulse count"
    static let HANDLE_HTTP_DOWNLOAD_FAILURE_CUMULATIVE_COUNT = "metrics collector: handle http download failure cumulative count"
    static let HANDLE_CDN_CONFIG_RECORDS = "metrics collector: handle cdn config records"
    static let HANDLE_CDN_DOWNLOAD_RECORD = "metrics collector: handle cdn download record"
    static let HANDLE_CDN_DOWNLOAD_LAST_MEAN_BANDWIDTH = "metrics collector: handle cdn download last mean bandwidth"
    static let HANDLE_CDN_DOWNLOAD_LAST_MEAN_AVAILABILITY = "metrics collector: handle cdn download last mean availability"
    static let HANDLE_CDN_DOWNLOAD_LAST_CURRENT_SCORE = "metrics collector: handle cdn download last current score"
    static let HANDLE_P2P_DOWNLOAD_RECORD = "metrics collector: handle p2p download record"
    static let HANDLE_TRACKER_STATE_RECORD = "metrics collector: handle tracker state record"
    static let HANDLE_NODE_STATE_RECORD = "metrics collector: handle node state record"
    static let HANDLE_SWARM_STATE_RECORD = "metrics collector: handle swarm state record"
    static let HANDLE_USER_STATE_RECORD = "metrics collector: handle user state record"
    static let HANDLE_PURGE_CDN_RECORDS = "metrics collector: handle purge cdn records"
    static let HANDLE_PRUNE_METRICS_STATS = "metrics collector: handle prune metrics stats"
}
