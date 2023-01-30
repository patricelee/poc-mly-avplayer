import MUXSDKStats

class MuxComponent {

    static var MUX_ENV_KEY: String = "gp0ku38e5c6fglvgp4is4e24d"

    static let playerData = MUXSDKCustomerPlayerData(environmentKey: MUX_ENV_KEY)

    static func monitor(playerLayer: AVPlayerLayer? = nil, playerViewController: AVPlayerViewController? = nil) -> MUXSDKPlayerBinding? {
        guard let playerData = playerData else {
            return nil
        }
        playerData.playerName = "AVPlayer"
        playerData.playerVersion = "0.1.0"
        playerData.viewerUserId = "P2spSDKAVPlayerUser1"
        playerData.experimentName = "P2spSDKAVPlayerExperiment1"
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "P2spSDKAVPlayerTitle"
        videoData.videoSeries = "P2spSDKAVPlayerSeries"
        videoData.videoIsLive = true
        videoData.videoCdn = "P2spSDK"
        guard let customerData = MUXSDKCustomerData(customerPlayerData: Self.playerData, videoData: videoData, viewData: nil, customData: nil, viewerData: nil) else {
            return nil
        }
        if let playerLayer = playerLayer {
            return MUXSDKStats.monitorAVPlayerLayer(playerLayer, withPlayerName: "AVPlayer", customerData: customerData)
        }
        if let playerViewController = playerViewController {
            return MUXSDKStats.monitorAVPlayerViewController(playerViewController, withPlayerName: "AVPlayer", customerData: customerData)
        }
        return nil
    }
    
}
