import Foundation

class Math {
    static func max<T: Comparable>(_ a: T, _ b: T) -> T {
        if a >= b {
            return a
        } else {
            return b
        }
    }

    static func min<T: Comparable>(_ a: T, _ b: T) -> T {
        if a <= b {
            return a
        } else {
            return b
        }
    }

    static func random() -> Double {
        return Double(arc4random()) / Double(UInt32.max)
    }
}
