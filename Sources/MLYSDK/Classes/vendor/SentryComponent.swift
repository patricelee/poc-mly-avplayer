import Foundation
import Sentry

class LoggerSentry: LoggerHandler {
    var level: LoggerLevel = .ERROR
    
    func log(_ level: LoggerLevel, _ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        if self.level.rawValue < level.rawValue { return }
        if let message = message {
            SentrySDK.capture(message: message)
        }
        if let error = options?.error {
            SentrySDK.capture(error: error)
        }
    }

}

class SentryComponent: Component {

    static var instance: SentryComponent?

    override init() {
        super.init()
        Self.instance = self
    }

    private static var SENTRY_DSN = "https://ae5860091d524009a29130553a1770f7@o255849.ingest.sentry.io/4504314925809664"

    override func activate() async {
        await super.activate()
        SentrySDK.start { options in
            options.dsn = Self.SENTRY_DSN
            options.debug = true
            options.tracesSampleRate = 0.8
            options.enableAppHangTracking = true
            options.enableFileIOTracking = true
            options.enableCoreDataTracking = true
            options.enableCaptureFailedRequests = true
        }
        Logger.loggers.append(LoggerSentry())
    }

    override func deactivate() async {
        await super.deactivate()
        Self.instance = nil
        SentrySDK.close()
    }
}
