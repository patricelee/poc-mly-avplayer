import Foundation

enum StatusCodes: Int {
    case OK = 200
    case FORBIDDEN = 403
    case NOT_FOUND = 404
    case SERVICE_UNAVAILABLE = 526
    case INTERNAL_SERVER_ERROR = 550
    case BAD_REQUEST = 601

}

class MessageCodeObject {
    var code: StatusCodes
    var logCode: String
    var metaCode: String
    var metaContent: String
    var logContent: String
    init(_ code: StatusCodes, _ logCode: String, _ metaCode: String, _ metaContent: String, _ logContent: String) {
        self.code = code
        self.logCode = logCode
        self.metaCode = metaCode
        self.metaContent = metaContent
        self.logContent = "(\(logCode)) \(logContent)"
    }

}
