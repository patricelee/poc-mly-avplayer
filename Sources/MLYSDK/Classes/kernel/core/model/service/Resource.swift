import Foundation

class Resource: Codable {
    var id: String
    var swarmID: String?
    var swarmURI: String?
    var sourceURI: String?
    var uri: String
    var type: String?
    var total: Int?
    lazy var ctime = WatchTool()
    lazy var mtime = WatchTool()
    var content: Data?
    var priority = 0
    var isShareable = false
    var isComplete: Bool = false
    var size: Int {
        return content?.count ?? 0
    }

    init(_ uri: String) {
        self.id = Resource.makeID(uri)
        self.uri = uri
    }

    func concat(options: Any) {}

    func nextRange() -> ResourceRange {
        return ResourceRange()
    }

    static func makeID(_ uri: String) -> String {
        var uc = URLComponents(string: uri)
        uc?.query = nil
        uc?.fragment = nil
        return HashTool.SHA256Base64(uc?.url?.absoluteString) ?? uri
    }
}

class ResourceRange {
    var start: Int?
    var end: Int?
}

class ResourceConcatOptions {
    var chunk: Data?
    var range: ResourceRange?
}

class ResourceStat {
    var id: String?
    var completion: Int?
}
