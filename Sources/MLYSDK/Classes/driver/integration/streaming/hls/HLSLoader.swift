import Foundation

class HLSLoader {
    static func load(_ url: String) async -> Resource? {
        let resource = Resource(url)
        return await FileSeekerHolder.fetch(resource)
    }
}

class HLSController {}
