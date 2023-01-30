
enum ReportSubmitterTaskName {
    static let HANDLE_CDN_DOWNLOAD_REPORT = "report submitter: handle cdn download report"
    static let HANDLE_P2P_DOWNLOAD_REPORT = "report submitter: handle p2p download report"
}

class ReportSubmitter {
    var _taskManager = TaskManager()
    func activate() async {
        await self._taskManager.activate()
        await self._buildTasks()
    }

    func deactivate() async {
        await self._taskManager.deactivate()
    }

    func _buildTasks() async {
        if KernelSettings.instance.report.isEnabled && Math.random() < KernelSettings.instance.report.sampleRate {
            await self._buildHandleCDNDownloadReportTask()
            await self._buildHandleP2PDownloadReportTask()
        }
    }

    func _buildHandleCDNDownloadReportTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: ReportSubmitterTaskName.HANDLE_CDN_DOWNLOAD_REPORT,
            flow: CDNDownloadReportHandler(),
            sleepFirst: true,
            sleepSeconds: 10,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }

    func _buildHandleP2PDownloadReportTask() async {
        await self._taskManager.createCyclicTask(TaskState(
            name: ReportSubmitterTaskName.HANDLE_P2P_DOWNLOAD_REPORT,
            flow: P2PDownloadReportHandler(),
            sleepFirst: true,
            sleepSeconds: 10,
            sleepJitter: 0,
            maxErrorRetry: -1,
            maxTotalRetry: -1
        ))
    }
}

struct CDNDownloadReportDutyContent: Codable {
    var cursor_data: HTTPDownloadRecord? = nil
    var reports: [HTTPDownloadRecord] = []
    var reportTime: TimeInterval = 0
    var isAborted: Bool = false
}

struct P2PDownloadReportDutyContent: Codable {
    var cursor_data: P2PDownloadRecord? = nil
    var reports: [P2PDownloadRecord] = []
    var reportTime: TimeInterval = 0
    var isAborted: Bool = false
}

class CDNDownloadReportHandler: AbstractFlow<CDNDownloadReportHandlerContent> {
    init() {
        super.init(content: .init())
    }

    override func process() async {
        await self._intakeIndex()
        await self._injectReports()
        while self._shouldSubmit {
            await self._submitReports()
        }
    }

    func _intakeIndex() async {
        let index = MetricsStatsHolder.source.http_download_records.lastIndex { record in
            record == self._content.cursor_data
        }
        await self._expose(FlowKey.INDEX, index)
    }

    func _injectReports() async {
        let records = MetricsStatsHolder.source.http_download_records
        let index = await self._require(FlowKey.INDEX) as? Int ?? 0
        self._content.reports.append(contentsOf: records[index..<records.count])
        self._content.cursor_data = records.last
    }

    var _shouldSubmit: Bool {
        return self._content.isAborted && self._content.reports.count > 0 && (self._content.reports.count >= ReportConstant.CDN_DOWNLOAD_REPORT_BATCH_SIZE || Date.now() - self._content.reportTime >= ReportConstant.MAX_DURATION_OF_REPORT_SUBMISSION)
    }

    func _submitReports() async {
        let reports = self._content.reports[0..<ReportConstant.CDN_DOWNLOAD_REPORT_BATCH_SIZE]
        await MeteringAPICreateCDNDownloadMeteringHandler.process(
            .init(
                records: reports.map { report in
                    .init(id: report.id, contentSize: report.contentSize, startTime: report.startTime, elapsedTime: report.elapsedTime, isSuccess: report.isSuccess, isComplete: report.isComplete, swarmURI: report.swarmURI, sourceURI: report.sourceURI, requestURI: report.requestURI, responseCode: report.responseCode, errorMessage: report.errorMessage, algorithmID: report.algorithmID, algorithmVersion: report.algorithmVersion)
                }
            ))

        self._content.reports.removeSubrange(0..<ReportConstant.CDN_DOWNLOAD_REPORT_BATCH_SIZE)
        self._content.reportTime = Date.now()
    }

    static func process(options: CDNDownloadReportHandlerOptions) async {
        await CDNDownloadReportHandler().process()
    }
}

typealias CDNDownloadReportHandlerContent = CDNDownloadReportDutyContent
typealias CDNDownloadReportHandlerOptions = CDNDownloadReportHandlerContent
class P2PDownloadReportHandler: AbstractFlow<P2PDownloadReportHandlerContent> {
    init() {
        super.init(content: .init())
    }

    override func process() async {
        await self._intakeIndex()
        await self._injectReports()
        while self._shouldSubmit() {
            await self._submitReports()
        }
    }

    func _intakeIndex() async {
        let index = MetricsStatsHolder.source.p2p_download_records.lastIndex { record in
            record == self._content.cursor_data
        }
        await self._expose(FlowKey.INDEX, index)
    }

    func _injectReports() async {
        let index = await self._require(FlowKey.INDEX) as! Int
        let records = MetricsStatsHolder.source.p2p_download_records
        self._content.reports = records[index..<records.count].filter { record in
            record.contentSize ?? -1 > 0 || record.totalSize ?? -1 == 0
        }
        self._content.cursor_data = self._content.reports.last!
    }

    func _shouldSubmit() -> Bool {
        return self._content.isAborted && self._content.reports.count > 0 && (self._content.reports.count >= ReportConstant.P2P_DOWNLOAD_REPORT_BATCH_SIZE || Date.now() - self._content.reportTime >= ReportConstant.MAX_DURATION_OF_REPORT_SUBMISSION)
    }

    func _submitReports() async {
        let reports = self._content.reports[0..<ReportConstant.P2P_DOWNLOAD_REPORT_BATCH_SIZE]

        await MeteringAPICreateP2PDownloadMeteringHandler.process(
            options: .init(
                records: reports.map({ report in
                    .init(
                        peerID: report.peerID,
                        contentSize: report.contentSize,
                        startTime: report.startTime,
                        elapsedTime: report.elapsedTime,
                        isComplete: report.isComplete,
                        swarmURI: report.swarmURI,
                        sourceURI: report.sourceURI,
                        requestURI: report.requestURI,
                        algorithmID: report.algorithmID,
                        algorithmVersion: report.algorithmVersion
                    )
                }
                )
            )
        )

        self._content.reports.removeSubrange(0..<ReportConstant.P2P_DOWNLOAD_REPORT_BATCH_SIZE)
        self._content.reportTime = Date.now()
    }

    static func process(options: P2PDownloadReportHandlerOptions) async {
        await P2PDownloadReportHandler().process()
    }
}

typealias P2PDownloadReportHandlerContent = P2PDownloadReportDutyContent
typealias P2PDownloadReportHandlerOptions = P2PDownloadReportHandlerContent

class ReportSubmitterHolder {
    static var _instance: ReportSubmitter?
    static var instance: ReportSubmitter? {
        get {
            return self._instance
        }
        set {
            self._instance = newValue
        }
    }
}
