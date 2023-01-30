import Foundation

public class MLYDriver {
    public init() {}

    static func config(options: MLYDriverOptions?) throws {
        try DriverManager.instance.config(options: options)
    }

    public static func initialize(options: MLYDriverOptions?) throws {
        
        Logger.error("error")
        try DriverManager.instance.initialize(options: options)
    }

    public static func activate() throws {
        DriverManager.instance.activate()
    }

    public static func deactivate() {
        DriverManager.instance.deactivate()
    }
}

class DriverManager {
    static var instance: DriverManager = .init()
    var supervisor = DriverSupervisor()
    var isActivated = false
    var isConfigured = false
    var isSupported = true

    func config(options: MLYDriverOptions?) throws {
        try DriverConfigurator.config(options: options)
        self.isConfigured = true
    }

    func initialize(options: MLYDriverOptions?) throws {
        try self.config(options: options)
        self.activate()
    }

    func activate() {
        guard self.isConfigured else {
            Logger.error(ValidationError(MessageCode.WSV001))
            return
        }
        Task {
            await self.supervisor.activate()
        }
        self.isActivated = true
    }

    func deactivate() {
        guard self.isActivated else {
            return
        }
        self.supervisor.deactivate()
        self.isActivated = false
    }
}
