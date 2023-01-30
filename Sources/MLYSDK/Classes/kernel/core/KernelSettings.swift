class KernelSettings {
    static var instance: KernelSettings = .init()

    var webrtc: WebRTCSettings = .init()
    var client: ClientSettings = .init()
    var server: ServerSettings = .init()
    var system: SystemSettings = .init()
    var stream: StreamSettings = .init()
    var report: ReportSettings = .init()
    var download: DownloadSettings = .init()
    var proxy: ProxySettings = .init()
    var platforms: PlatformConfigResponse = .init()
}

struct WebRTCSettings {
    var options: RTCConfiguration = .init()
}

struct RTCConfiguration {}

struct ClientSettings {
    var id: String?
    var key: String?
    var token: String?
    var origin: String? = "null"
    var peerID: String?
    var sessionID: String? = SessionID.make()
}

struct ServerVersion {
    var fqdn: String = "vsp.mlytics.com"
    var version: String = "v1"
}

struct ServersVersion {
    var fqdns: [String?] = []
    var version: String = "v1"
}

struct ServerSettings {
    var host: ServerVersion = .init()
    var token: ServerVersion = .init()
    var config: ServerVersion = .init()
    var cdnScore: ServerVersion = .init()
    var metering: ServerVersion = .init()
    var tracker: ServersVersion = .init()
}

struct SystemSettings {
    var mode: String = "none"
    var isP2PAllowed: Bool = false
}

struct StreamSettings {
    var streamID: String = ""
    var maxBufferTime: TimeInterval = 1
    var maxBufferSize: Int = 8192
}

struct ReportSettings {
    var isEnabled: Bool = false
    var sampleRate: Double = 1.0
}

struct DownloadSettings {
    var maxCacheItems: Int = 8192
    var maxP2PPossibility: Double = 1.0
    var httpInitialTimeout: TimeInterval = 10
    var httpResponseTimeout: TimeInterval = 20
}

struct ProxySettings {
    var port: UInt = 34567
    var host: String = "127.0.0.1"
    var scheme: String = "http"
}

enum SessionID {
    static let TIME_PART_FORMAT = "YYYYMMDDHHmmss"
    static let RANDOM_PART_LENGTH = 20

    static func make() -> String {
        let timePart = TimeTool.makeNowFstring(Self.TIME_PART_FORMAT)
        let randomPart = ByteTool.makeRandomBase36String(Self.RANDOM_PART_LENGTH)
        return "session-\(timePart)-\(randomPart)"
    }
}

class DriverInfo {
    var sessionID: String? {
        return KernelSettings.instance.client.sessionID
    }
}

class KernelValidator {
    static let ID = try! ValidTool("^[0-9a-z]{20}$", true)
    static let KEY = try! ValidTool("^[0-9a-z]{32}$", true)
    var options: MLYDriverOptions?

    init(_ options: MLYDriverOptions?) {
        self.options = options
    }

    func verify() throws {
        try verify_()
    }

    func verify_() throws {
        try verifySchema_()
        try verifyClientID_()
        try verifyClientKey_()
    }

    func verifySchema_() throws {}

    func verifyClientID_() throws {
        guard Self.ID.valid(options?.client.id) else {
            throw ValidationError(MessageCode.WSV001)
        }
    }

    func verifyClientKey_() throws {
        guard Self.KEY.valid(options?.client.key) else {
            throw ValidationError(MessageCode.WSV001)
        }
    }

    public static func verify(options: MLYDriverOptions?) throws {
        try KernelValidator(options).verify()
    }
}

class KernelConfigurator {
    var options: MLYDriverOptions?
    init(_ options: MLYDriverOptions?) {
        self.options = options
    }

    func config() {
        KernelSettings.instance.client.id = options?.client.id
        KernelSettings.instance.client.key = options?.client.key
    }

    static func config(options: MLYDriverOptions?) {
        KernelConfigurator(options).config()
    }
}
