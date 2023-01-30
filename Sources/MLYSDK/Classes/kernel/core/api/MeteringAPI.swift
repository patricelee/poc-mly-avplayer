class MeteringAPICreateCDNDownloadMeteringHandler: AbstractFlow<MeteringAPICreateCDNDownloadMeteringContent> {
    override func process() async {
        await self._intakeData()
        await self._forwardData()
    }

    func _intakeData() async {
        let records = self._content.records
        let kernelSettings = KernelSettings.instance
        let data = MeteringAPICreateCDNDownloadMeteringData(
            data: records.map { record in
                MeteringAPICreateCDNDownloadMeteringDataItem(
                    time: record.startTime, streamID: kernelSettings.stream.streamID, clientID: kernelSettings.client.id, sessionID: kernelSettings.client.sessionID, ok: record.isSuccess, error: record.errorMessage, httpCode: record.responseCode, url: record.requestURI, masterURL: record.swarmURI, sourceURL: record.sourceURI, hostname: kernelSettings.client.origin, platformID: record.id, transferSize: record.contentSize, duration: record.elapsedTime, isComplete: record.isComplete, sampleRate: kernelSettings.report.sampleRate, algorithmID: record.algorithmID, algorithmVer: record.algorithmVersion
                )
            })
        await self._expose(FlowKey.DATA, data)
    }

    func _forwardData() async {
        let data = await self._require(FlowKey.DATA) as! MeteringAPICreateCDNDownloadMeteringData
        _ = try? await MeteringRequester().createCDNDownloadMetering(
            options: data
        )
    }

    static func process(_ options: MeteringAPICreateCDNDownloadMeteringContent) async {
        await MeteringAPICreateCDNDownloadMeteringHandler(
            content: options
        ).process()
    }
}

class MeteringAPICreateP2PDownloadMeteringHandler: AbstractFlow<MeteringAPICreateP2PDownloadMeteringContent> {
    override func process() async {
        await self._intakeData()
        await self._forwardData()
    }

    func _intakeData() async {
        let records = self._content.records
        let kernelSettings = KernelSettings.instance
        let data = MeteringAPICreateP2PDownloadMeteringOptions(
            data: records.map { record in
                MeteringAPICreateP2PDownloadMeteringOptionsItem(
                    time: record.startTime,
                    streamID: kernelSettings.stream.streamID,
                    clientID: kernelSettings.client.id,
                    sessionID: kernelSettings.client.sessionID,
                    peerID: kernelSettings.client.peerID,
                    peerType: PeerType.USER,
                    targetPeerID: record.peerID,
                    targetPeerType: PeerType.USER,
                    url: record.requestURI,
                    masterURL: record.swarmURI,
                    sourceURL: record.sourceURI,
                    transferType: TransferType.DOWNLOAD,
                    transferSize: record.contentSize,
                    duration: record.elapsedTime,
                    isComplete: record.isComplete,
                    sampleRate: kernelSettings.report.sampleRate,
                    algorithmID: record.algorithmID,
                    algorithmVer: record.algorithmVersion
                )
            }
        )
        await self._expose(FlowKey.DATA, data)
    }

    func _forwardData() async {
        let data = await self._require(FlowKey.DATA) as! MeteringAPICreateP2PDownloadMeteringOptions
        _ = try? await MeteringRequester().createP2PDownloadMetering(
            options: data
        )
    }

    static func process(options: MeteringAPICreateP2PDownloadMeteringContent) async {
        _ = await MeteringAPICreateP2PDownloadMeteringHandler(
            content: options
        ).process()
    }
}
