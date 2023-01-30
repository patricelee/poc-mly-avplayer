import Foundation
import AVKit
import AVFoundation


public enum MLYAVPlayerPlugin {
    public static func adapt(playerLayer: AVPlayerLayer? = nil, playerViewController: AVPlayerViewController? = nil) {
        _ = MLYAVPlayerAdapter(playerLayer: playerLayer, playerViewController: playerViewController)
    }
}

public class MLYAVPlayerAdapter {
    public init(playerLayer: AVPlayerLayer? = nil, playerViewController: AVPlayerViewController? = nil) {
        _ = MuxComponent.monitor(playerLayer: playerLayer, playerViewController: playerViewController)
    }
}
