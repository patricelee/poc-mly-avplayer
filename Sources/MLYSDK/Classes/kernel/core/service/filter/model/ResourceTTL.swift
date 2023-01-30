let resourceTTLPool: [String: TimeInterval] = [
    ContentType.HLS_M3U.rawValue:
        ResourceTTL.TWO_SECOND,
    ContentType.HLS_M3U_2.rawValue:
        ResourceTTL.TWO_SECOND,
    ContentType.HLS_M3U8.rawValue:
        ResourceTTL.TWO_SECOND,
    ContentType.HLS_M3U8_2.rawValue:
        ResourceTTL.TWO_SECOND,
    ContentType.HLS_TS.rawValue:
        ResourceTTL.TWO_HOUR
]

enum ResourceTTL {
    static let ONE_DAY: TimeInterval = 24 * 60 * 60
    static let TWO_HOUR: TimeInterval = 2 * 60 * 60
    static let TWO_SECOND: TimeInterval = 2
}

enum ResourceTTLSuggester {
    static let DEFAULT_RESOURCE_TTL: TimeInterval = ResourceTTL.TWO_HOUR
    static func give(_ resource: Resource) -> TimeInterval {
        if let type = resource.type {
            if let ttl = resourceTTLPool[type] {
                return ttl
            }
        }
        return ResourceTTLSuggester.DEFAULT_RESOURCE_TTL
    }
}
