class TimeTool {

    static func makeNowFstring(_ format: String) -> String {
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.string(from: Date())
    }

}
