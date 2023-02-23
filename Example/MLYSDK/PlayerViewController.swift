import AVFoundation
import AVKit
import MLYSDK
import SnapKit
import UIKit

class PlayerViewController: UIViewController {
    var player: AVPlayer!
    var playerViewController: AVPlayerViewController!
    var playerItem: AVPlayerItem!
    var playButton: UIButton!

    var plugin: MLYAVPlayerPlugin = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        self.player = .init()
        self.playerViewController = .init()
        self.playerViewController.showsPlaybackControls = true
        self.playerViewController.player = self.player
        self.addChild(self.playerViewController)
        self.view.addSubview(self.playerViewController.view)

        self.playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.playerViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.playButton = addButton("Play", #selector(self.playVideo), top: -20, left: -20)

        self.view.layoutIfNeeded()

        self.setupDriver()
        self.plugin.adapt(self.playerViewController)
    }

    @objc func playVideo() {
        debugPrint("Play Video")
        let url = URL(string: "https://vsp-stream.s3.ap-northeast-1.amazonaws.com/HLS/raw/SpaceX.m3u8")!
        Task {
            await MLYDriver.ready()
            let playerItem = AVPlayerItem(url: url)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.play()
        }
    }

    @objc func setupDriver() {
        debugPrint("setupDriver")
        do {
            try MLYDriver.initialize { options in
                options.client.id = "cegh8d9j11u91ba1u600"
                options.debug = false
            }
        } catch {
            print(error)
        }
    }
}

extension UIViewController {
    func addButton(_ title: String, _ action: Selector, top: Double = 20, left: Double = 20) -> UIButton {
        let v = UIButton()
        v.setTitle(title, for: .normal)
        v.setTitleColor(.white, for: .normal)
        self.view.addSubview(v)
        if top < 0 {
            v.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: top).isActive = true
        } else {
            v.topAnchor.constraint(equalTo: self.view.topAnchor, constant: top).isActive = true
        }
        if left < 0 {
            v.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: left).isActive = true
        } else {
            v.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: left).isActive = true
        }
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: action, for: .touchUpInside)
        return v
    }
}
