class AbstractDownloader {
    var _isAborted = false
    var _resource: Resource
    var _task: SpecTask?

    required init(
        _ _resource: Resource)
    {
        self._resource = _resource
    }

    func fetch() async throws {
        try await self._fetch()
        try await self._throwIfAborted()
    }

    func _fetch() async throws {
        Logger.error("AbstractDownloader._fetch didnot implemented")
    }

    func abort() async {
        self._isAborted = true
        await self._abort()
    }

    func _abort() async {
        Logger.error("AbstractDownloader._abort didnot implemented")
    }

    func _throwIfAborted() async throws {
        if self._isAborted {
            throw InternalError(MessageCode.ESC001, nil, [self._resource.id: self._resource])
        }
    }
}
