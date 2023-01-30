protocol SpecComponent {
    var isActivated: Bool { get set }
    var isRunning: Bool { get set }

    func activate() async
    func deactivate() async
    func reactivate() async
}

class Component: SpecComponent {
    var isActivated = false
    var isRunning = false

    func activate() async {
        self.isActivated = true
    }

    func deactivate() async {
        self.isActivated = false
    }

    func reactivate() async {
        await deactivate()
        await activate()
    }
}
