import Foundation

class JSONTool {
    
    static func dumps(_ obj: Encodable) -> String? {
        
        if obj is String {
            return obj as? String
        }
        if obj is Int || obj is Double {
            return "\(obj)"
        }
        
        if let arr = obj as? [Encodable] {
            var sb = ""
            for v in arr {
                if !sb.isEmpty {
                    sb.append(",")
                }
                sb.append(Self.dumps(v) ?? "")
            }
            return sb
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(obj)
            let str = String(data: data, encoding: .utf8)
            return str
        }catch let error {
            Logger.error("JSONTool.dumps", error)
        }
        return nil
    }
}
