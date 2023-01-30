class ReportComponent: Component {
    var _provider: ReportProvider
    override init() {
        self._provider = ReportProvider()
        super.init()
    }

    func _initialize() {
        
    }

    func _create() async {
        await self._provider.activate()
    }

    func _destroy() async {
        await self._provider.deactivate()
    }
}
