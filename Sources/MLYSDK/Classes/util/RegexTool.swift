import Foundation

class RegexTool {
    var reg: NSRegularExpression
    init(_ reg: String) throws {
        self.reg = try NSRegularExpression(pattern: reg, options: .caseInsensitive)
    }

    func matches(_ string: String?) -> Bool {
        guard let string = string else {
            return false
        }
        let range = NSRange(location: 0, length: string.count)
        let result = self.reg.firstMatch(in: string, options: .reportProgress, range: range)
        return result != nil
    }

    func replace(_ string: String, _ map: [String: String]) -> String {
        let translate: (String.SubSequence) -> String = { s in
            return map[String(s)] ?? ""
        }
        return replace(string, translate)
    }

    func replace(_ string: String, _ translate: (String.SubSequence) -> String) -> String {
        let range = NSRange(location: 0, length: string.count)
        var res = ""
        var last = string.startIndex
        let matchs = self.reg.matches(in: string, options: .reportCompletion, range: range)
        for result in matchs {
            let start = string.index(string.startIndex, offsetBy: result.range.lowerBound)
            let end = string.index(string.startIndex, offsetBy: result.range.upperBound)
            print(result.range.lowerBound, result.range.upperBound)
            let prefix = string[last ..< start]
            res.append(contentsOf: prefix)
            let s = string[start ..< end]
            let r = translate(s)
            res.append(contentsOf: r)
            last = end
        }
        let end = string.endIndex

        let r = string[last ..< end]
        res.append(contentsOf: r)
        return res
    }
}
