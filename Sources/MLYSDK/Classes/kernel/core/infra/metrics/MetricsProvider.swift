class MetricsProvider: Component {
    override func activate() async {
        await self._loadMetricsStats()
        await self._loadMetricsCollector()
    }

    func _loadMetricsStats() async {
        MetricsStatsHolder.instance = MetricsStats()
    }

    func _loadMetricsCollector() async {
        let metricsCollector = MetricsCollector()
        await metricsCollector.activate()
        MetricsCollectorHolder.instance = metricsCollector
    }

    override func deactivate() async {
        await self._unloadMetricsCollector()
        await self._unloadMetricsStats()
    }

    func _unloadMetricsCollector() async {
        let metricsCollector = MetricsCollectorHolder.instance
        await metricsCollector?.deactivate()
        MetricsCollectorHolder.instance = nil
    }

    func _unloadMetricsStats() async {
        let metricsStats = MetricsStatsHolder.instance
        metricsStats?.reset()
        MetricsStatsHolder.instance = nil
    }
}
