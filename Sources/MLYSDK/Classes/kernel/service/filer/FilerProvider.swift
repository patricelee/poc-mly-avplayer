class FilerProvider: Component {
    override func activate() async {
        await self._loadFileSeeker()
    }

    func _loadFileSeeker() async {
        let fileSeeker = FileSeeker()
        await fileSeeker.activate()
        FileSeekerHolder.instance = fileSeeker
    }

    override func deactivate() async {
        await self._unloadFileSeeker()
    }

    func _unloadFileSeeker() async {
        let fileSeeker = FileSeekerHolder.instance
        await fileSeeker?.deactivate()
        FileSeekerHolder.instance = nil
    }
}
