import Foundation

class ValidTool {
    static let PHONE = try! ValidTool("^+?{0-9}{10,}$")
    var required: Bool = false
    var reg: RegexTool?

    init(_ reg: String?, _ required: Bool = false) throws {
        if let reg = reg {
            self.reg = try RegexTool(reg)
        }
    }

    func valid(_ val: String?) -> Bool {
        if val == nil {
            return required
        }
        guard let reg = self.reg else { return true }
        return reg.matches(val)
    }

}
