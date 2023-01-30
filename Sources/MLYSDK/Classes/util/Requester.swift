import Foundation

class Requester {
    var host: String = ""
    var timeout: TimeInterval = 30

    init() {}

    init(_ host: String = "", timeout: TimeInterval = 30) {
        setHost(host)
        self.timeout = timeout
    }

    func setHost(_ host: String) {
        if host.isEmpty {
            self.host = host
            return
        }

        if host.starts(with: "http") {
            self.host = host
        } else {
            self.host = "https://\(host)"
        }
    }

    func fetch<T>(_ path: String, type: T.Type, queries: [String: Encodable?] = [:], headers: [String: String?] = [:],
                  aborter: AbortController? = nil,
                  timeout: TimeInterval? = nil) async throws -> T? where T: Decodable
    {
        let res = try await fetch(path, queries: queries, headers: headers, aborter: aborter, timeout: timeout)
        let decoder = JSONDecoder()
        if let data = res?.data {
            let res = try decoder.decode(type, from: data)
            return res
        }
        return nil
    }

    func fetch(_ path: String, queries: [String: Encodable?] = [:], headers: [String: String?] = [:],
               aborter: AbortController? = nil,
               timeout: TimeInterval? = nil) async throws -> RequesterResult?
    {
        let res = RequesterResult()
        let url = "\(host)\(path)"

        var uc = URLComponents(string: url)!
        uc.queryItems = Self.buildQueryItems(queries)

        guard let u = uc.url else {
            Logger.error("http error: nil url=\(url)")
            return nil
        }

        var req = URLRequest(url: u, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout ?? self.timeout)
        for (k, v) in headers {
            if let v = v {
                req.setValue(v, forHTTPHeaderField: k)
            }
        }
        Logger.debug("http req \(u.absoluteString) \(headers) ")
        await withCheckedContinuation { con in
            let task = URLSession.shared.dataTask(with: req) { data, resp, error in
                if let data = data {
                    if data.count < 8192, let str = String(data: data, encoding: .utf8) {
                        Logger.debug("http resp \(u.absoluteString) count=\(data.count) data=\(str)")
                    } else {
                        Logger.debug("http resp \(u.absoluteString) count=\(data.count)")
                    }
                }
                res.data = data
                res.response = resp as? HTTPURLResponse
                res.error = error
                con.resume()
            }
            task.resume()
        } as Void
        try res.throwIfError()
        return res
    }

    static func buildQueryItems(_ queries: [String: Encodable?]) -> [URLQueryItem] {
        return queries.compactMap { k, v in
            buildQueryItem(k, v)
        }
    }

    static func buildQueryItem(_ key: String, _ value: Encodable?) -> URLQueryItem? {
        guard let value = value else {
            return nil
        }
        if let str = value as? String {
            return URLQueryItem(name: key, value: str)
        }
        if let str = JSONTool.dumps(value) {
            return URLQueryItem(name: key, value: str)
        }
        return nil
    }
}

class RequesterResult {
    var data: Data?
    var response: HTTPURLResponse?
    var error: Error?
    var statusCode: Int? {
        return self.response?.statusCode
    }

    func throwIfError(_ error: Error? = nil) throws {
        if let err = self.error {
            Logger.error("http error", err)
            throw error ?? err
        }
    }
}
