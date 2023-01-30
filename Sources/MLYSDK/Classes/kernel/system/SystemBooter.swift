import Foundation

class SystemBooter {
    var isActivated = false
    var components: [Component] = []

    func activate() async {
        register()
        for val in self.components {
            await val.activate()
        }
        self.isActivated = true
    }

    func deactivate() async {
        for val in self.components.reversed() {
            await val.deactivate()
        }
        self.isActivated = false
    }

    func available() -> Bool {
        guard self.isActivated else { return false }
        for val in self.components {
            guard val.isActivated else { return false }
        }
        return true
    }

    func register(_ component: Component) {
        self.components.append(component)
    }

    func register() {
        register(ProxyComponent())
        register(SystemComponent())
        register(MCDNComponent())
//        register(CentrifugeComponent())
//        register(MCDNComponent_())
        register(CacheComponment())
        register(FilerProvider())
        register(MetricsProvider())
    }
}

enum SystemBooterHolder {
    static var instance = SystemBooter()

    static func available() -> Bool {
        return Self.instance.available()
    }
}
