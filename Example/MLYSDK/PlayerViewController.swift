import AVFoundation
import AVKit
import MLYSDK
import SnapKit
import UIKit

class PlayerViewController: UIViewController {
    lazy var player = AVPlayer()
    lazy var playerViewController = {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = true
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.backgroundColor = .darkGray
        controller.player = self.player
        return controller
    }()

    lazy var plugin = MLYAVPlayerPlugin()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

        do {
            try MLYDriver.initialize { options in
                options.client.id = "cegh8d9j11u91ba1u600"
            }
            self.plugin.adapt(self.playerViewController)
        } catch {
            print(error)
        }

        let url = URL(string: "https://vsp-stream.s3.ap-northeast-1.amazonaws.com/HLS/raw/SpaceX.m3u8")!
        let playerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: playerItem)
        self.player.play()
    }

    func setupUI() {
        self.view.backgroundColor = .black
        self.addChild(self.playerViewController)
        self.view.addSubview(self.playerViewController.view)
        self.playerViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
