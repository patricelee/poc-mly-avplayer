class TimeSeriesDataLike: Codable {
    var ctime:TimeInterval?
    init(ctime: TimeInterval? = Date.now()) {
        self.ctime = ctime
    }
}
