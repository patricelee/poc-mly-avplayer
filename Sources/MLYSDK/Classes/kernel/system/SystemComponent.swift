class SystemComponent: Component {
    lazy var initializer = SystemInitializer()

    override func activate() async {
        _ = await self.initializer.process()
        self.isActivated = true
    }
}
