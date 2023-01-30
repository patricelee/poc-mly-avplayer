import Foundation

public class ProxyURLModifier {
    public static func replace(_ url: String) throws -> URL {
        guard var uc = URLComponents(string: url) else {
            throw ProxyURLModifierError.IllegalURLFormat
        }
        uc.scheme = KernelSettings.instance.proxy.scheme
        uc.host = KernelSettings.instance.proxy.host
        uc.port = Int(KernelSettings.instance.proxy.port)
        guard let result = uc.url else {
            throw ProxyURLModifierError.IllegalURLFormat
        }
        CDNOriginKeeper.setOrigin(url)
        return result
    }
}

public enum ProxyURLModifierError: Error {
    case IllegalURLFormat
}
