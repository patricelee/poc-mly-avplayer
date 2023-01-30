class FileDownloader: AbstractFileDownloader {
    required init(
        _ _resource: Resource)
    {
        super.init(_resource)
        _initialize()
    }

    override func _initialize() {
        _proxyAgent = DownloaderAgent()
    }

    override func _fetch() async throws {
        defer {
            //            let swarmDaemon = swarmDaemonPool.retrieve(_resource.swarmID!)
            //            if (swarmDaemon && _resource.isShareable) {
            //                swarmDaemon.command<pipes.LaunchReportResourceStatPipe>({ // No need to await.
            //                    id: FlowID.make(),
            //                    name: SwarmProcessPipeName.LAUNCH_REPORT_RESOURCE_STAT,
            //                    content: {
            //                        info: swarmDaemon.info,
            //                        resourceID: _resource.id
            //                    }
            //                }).catch(async (error) => {
            //                    const resource = _resource
            //                    await Logger.debug('Report resource stat failed.', {resource}, {error})
            //                })
            //            }
        }

        try await super._fetch()
    }
}
