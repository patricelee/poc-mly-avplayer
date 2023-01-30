class ReportProvider {
    func activate() async {
        await self._loadReportSubmitter()
    }

    func _loadReportSubmitter() async {
        let reportSubmitter = ReportSubmitter()
        await reportSubmitter.activate()
        ReportSubmitterHolder.instance = reportSubmitter
    }

    func deactivate() async {
        await self._unloadReportSubmitter()
    }

    func _unloadReportSubmitter() async {
        let reportSubmitter = ReportSubmitterHolder.instance
        await reportSubmitter?.deactivate()
        ReportSubmitterHolder.instance = nil
    }
}
