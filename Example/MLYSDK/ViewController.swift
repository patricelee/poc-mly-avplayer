import AVFoundation
import AVKit
import MLYSDK
import UIKit

class ViewController: UIViewController {
    var playerItem: AVPlayerItem?
    var player: AVPlayer?

    var bytes: Int = 0
    var playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    var restartButton: UIButton = {
        let button = UIButton()
        button.setTitle("Restart", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    public var driver = MLYDriver()

    override func viewDidLoad() {
        super.viewDidLoad()

        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        playButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true

        restartButton.addTarget(self, action: #selector(restart), for: .touchUpInside)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(restartButton)
        restartButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        restartButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true

        player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)

        restart()
        MLYAVPlayerPlugin.adapt(playerLayer: playerLayer)

        view.layoutIfNeeded()
    }

    @objc func playVideo() {
        do {
            let url = try ProxyURLModifier.replace(play_m3u8)
            playerItem = AVPlayerItem(url: url)
            playerItem?.preferredForwardBufferDuration = 15
            player?.replaceCurrentItem(with: playerItem)
            player?.play()
        } catch {
            print(error)
        }
    }

    @objc func restart() {
        MLYDriver.deactivate()
        var options: MLYDriverOptions {
            let options = MLYDriverOptions()
            options.client.id = client_id
            return options
        }
        do {
            try MLYDriver.initialize(options: options)
        } catch {
            print(error)
        }
    }
}
