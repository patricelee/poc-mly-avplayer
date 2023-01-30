import Foundation
import CommonCrypto
import CryptoKit

class HashTool {

    static func SHA256Data(_ data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }

    static func SHA256Base64(_ string: String?) -> String? {
        guard let from = string?.data(using: .ascii) else { return nil }
        let to = SHA256Data(from)
        let result = to.base64EncodedString()
        return result
    }

    static func SHA256Base64URL(_ string: String?) -> String? {
        let to = SHA256Base64(string)
        let result = Base64URL(to)
        return result
    }

    static let URL_REG = try! RegexTool("[+/=]{1}")
    static let URL_MAP = ["/": "_", "+": "-", "=": ""]
    static func Base64URL(_ string: String?) -> String? {
        guard let string = string else { return nil }
        return URL_REG.replace(string, URL_MAP)
    }

    static func HEX(_ data: Data) -> String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }

    static func SHA256Base16(_ string: String?) -> String? {
        guard let from = string?.data(using: .ascii) else { return nil }
        let to = SHA256Data(from)
        let result = HEX(to)
        return result
    }

}
