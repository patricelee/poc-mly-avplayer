enum BaseComponentName {
    static let SYSTEM = "system"
    static let METRICS = "metrics"
    static let REPORT = "report"
    static let FILER = "filer"
}

enum BaseComponentBundle {
    static let REQUIRED = [
        BaseComponentName.SYSTEM,
        BaseComponentName.METRICS,
        BaseComponentName.REPORT,
        BaseComponentName.FILER
    ]
}
