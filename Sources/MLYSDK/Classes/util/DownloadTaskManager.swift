import Foundation

class DownloadTaskManager: NSObject {

    lazy private var downloads: [String: DownloadTask] = [:]
    var timeout: TimeInterval

    init(_ timeout: TimeInterval = 60) {
        self.timeout = timeout
    }

    func activate() async {

    }
    func deactivate() async {
        self.purgeTasks()
    }

    private func build(_ url: URL, _ command: DownloadTask.Command = .download, headers: [String: String] = [:]) -> DownloadTask? {
        guard let url = Self.standard(url) else {
            Logger.error("DownloadTaskManager.build nil url")
            return nil
        }
        if let download = self.downloads[url.absoluteString] {
            switch command {
            case .abort:
                download.abort()
            case .exit:
                download.exit()
            case .download:
                download.resume()
            }
            return download
        }
        if command != .download {
            Logger.error("command must be .download, but \( command )")
        }
        let download = DownloadTask(url, timeout: self.timeout, headers:headers)
        self.downloads[url.absoluteString] = download
        download.start()
        return download
    }

    func abort(_ url: URL) -> DownloadTask? {
        return build(url, .abort)
    }
    func exit(_ url: URL) {
        _ = build(url, .exit)
        self.downloads.removeValue(forKey: url.absoluteString)
    }
    func create(_ url: URL, headers: [String:String] = [:]) -> DownloadTask? {
        return self.build(url, .download, headers:headers)
    }

    func purgeTasks() {
        for t in self.downloads.values {
            t.exit()
        }
    }
}

class DownloadTask: NSObject, SpecTask {
    var isCompleted: Bool? {
        return task?.state == .completed || error != nil
    }

    var isAborted: Bool? {
        return task?.state == .suspended
    }

    var url: URL
    var timeout: TimeInterval
    var task: URLSessionDownloadTask?
    var response: HTTPURLResponse?
    var data: Data?
    var type: String?
    var headers: [String: String]

    var taskState: URLSessionTask.State? {
        return self.task?.state
    }
    var state: Int? {
        return self.response?.statusCode
    }
    var error: Error?
    lazy var condition = Condition()

    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()

    init(_ url: URL, timeout: TimeInterval = 60, headers: [String: String] = [:]) {
        self.url = url
        self.timeout = timeout
        self.headers = headers
    }

    func done() async {
        if self.taskState == .completed {
            return
        }
        await self.condition.done()
        Logger.debug("download done \(self.url.absoluteString) \(self.data?.count ?? -1)")
    }
    
    func throwIfError() async throws {
        if let error = self.error {
            Logger.error("download error \(self.url.absoluteString)", error)
            throw error
        }
    }

    func start() {
        Logger.debug("download start \(url.absoluteString)")
        var req = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
        for (k,v) in self.headers {
            req.setValue(v, forHTTPHeaderField: k)
        }
        self.task = session.downloadTask(with: req, completionHandler: { [unowned self] (url, resp, error) in
            self.complete(url, resp, error)
        })
        self.task?.resume()
    }
    func complete(_ url: URL?, _ resp: URLResponse?, _ error: Error?) {

        if let error = error {
            Logger.error("download error", error)
        }

        self.data = self.read(url)
        self.type = self.getResponseHeader(HTTPHeader.CONTENT_TYPE)
        self.response = resp as? HTTPURLResponse
        self.error = error
        self.condition.pass(error)
    }

    func abort() {
        self.task?.cancel(byProducingResumeData: { [unowned self] data in
            self.data = data
            self.condition.pass()
        })
    }
    func exit() {
        self.data = nil
        self.task?.cancel(byProducingResumeData: { [unowned self] _ in
            self.condition.pass()
        })
    }
    func resume(headers: [String: String] = [:]) {
        guard taskState == .suspended else { return }
        guard let data = data else { return }
        self.task = self.session.downloadTask(withResumeData: data, completionHandler: { [unowned self] (url, resp, error) in
            complete(url, resp, error)
        })
        self.task?.resume()
    }
    func read(_ url: URL?) -> Data? {
        guard let url = url else {
            Logger.error("download error: nil data")
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            Logger.error("download error: nil data")
            return nil
        }
        return data
    }
    func getResponseHeader(_ header: String) -> String? {
        if let resp = response {
            return resp.allHeaderFields[header] as? String
        }
        return nil
    }
}

extension DownloadTaskManager {
    static func standard(_ url: URL) -> URL? {
        guard var uc = URLComponents(string: url.absoluteString) else {
            Logger.error("nil url: \(url.absoluteString)")
            return nil
        }
        uc.fragment = nil
        guard let u = uc.url else {
            Logger.error("nil url: \(url.absoluteString)")
            return nil
        }
        return u
    }
}

extension DownloadTask {
    enum Command: Int {
        case download = 0
        case abort
        case exit
    }
}

extension DownloadTask: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let url = downloadTask.currentRequest?.url?.absoluteString ?? "invalid url"
        Logger.info("received: \(url), \(totalBytesWritten), \(totalBytesExpectedToWrite)")
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

    }
}

protocol DownloadTaskDelegate {
    func success(_ download: DownloadTask)
    func cancel(_ download: DownloadTask)
    func error(_ download: DownloadTask)
}

class DefaultDownloadTaskDelegate: DownloadTaskDelegate {
    func success(_ download: DownloadTask) { }
    func cancel(_ download: DownloadTask) { }
    func error(_ download: DownloadTask) { }
}

protocol SpecTask {
    var state: Int? {get}
    var data: Data? {get}
    var type: String? {get}
    var isCompleted: Bool? {get}
    var isAborted: Bool? {get}
    func done() async
    func abort()
    func exit()
    func throwIfError() async throws
}
