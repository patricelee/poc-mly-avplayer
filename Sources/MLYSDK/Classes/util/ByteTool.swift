class ByteTool {

    static let letters: NSString = "0123456789abcdefghijklmnopqrstuvwxyz"
    static let len = UInt32(letters.length)
    static func makeRandomBase36String(_ length: Int) -> String {
        var randomString = ""
        for _ in 0 ..< length {
            let rand = Int(arc4random_uniform(Self.len))
            var char = Self.letters.character(at: rand)
            randomString += NSString(characters: &char, length: 1) as String
        }
        return randomString
    }

    static func randomDouble() -> Double {
        return Double(arc4random()) / Double(UInt32.max)
    }

}
