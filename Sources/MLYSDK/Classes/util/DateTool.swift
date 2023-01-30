import Foundation

extension Date {
    static func now() -> TimeInterval {
        return Self().timeIntervalSince1970
    }
}
