enum ContentType: String {
    case XML = "application/xml"
    case JSON = "application/json"
    case BYTE = "application/octet-stream"
    case TEXT = "text/plain"
    case FILE = "multipart/form-data"
    case FORM = "application/x-www-form-urlencoded"
    case HTML = "text/html"
    case WEBVTT = "text/vtt"
    case HLS_M3U = "audio/mpegurl"
    case HLS_M3U_2 = "audio/x-mpegurl"
    case HLS_M3U8 = "application/vnd.apple.mpegurl"
    case HLS_M3U8_2 = "application/x-mpegurl"
    case HLS_TS = "video/mp2t"
    
    init(url: URL) {
        if url.path.contains(".m3u8") {
            self = .HLS_M3U8_2
        }else {
            self = .HLS_TS
        }
    }
}
