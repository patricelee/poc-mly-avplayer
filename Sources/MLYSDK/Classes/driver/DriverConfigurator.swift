import Foundation

class DriverConfigurator {
    var options: MLYDriverOptions?
    init(_ options: MLYDriverOptions?) {
        self.options = options
    }

    func config() throws {
        try KernelValidator(self.options).verify()
        KernelConfigurator(self.options).config()
    }

    static func config(options: MLYDriverOptions?) throws {
        try DriverConfigurator(options).config()
    }
}

public class MLYDriverOptions {
    public var client: MLYClientOptions = .init()
    public init() {}
}

public struct MLYClientOptions {
    public var id: String?
    public var key: String?
}
