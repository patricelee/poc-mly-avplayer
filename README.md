# poc-mly-avplayer 

[![Language](https://img.shields.io/badge/Swift-5.0-green.svg?style=flat)](http://cocoapods.org/pods/MLYSDK) 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MLYSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile: 

### Cocoapods

```bash
pod 'MLYSDK' 
```

or

```bash
pod 'MLYSDK',:git => 'https://github.com/patricelee/poc-mly-avplayer.git'
```

## Usage

### 1 - Prepare  ###
 
```swift
var player = AVPlayer()
let playerLayer = AVPlayerLayer(player: player)
playerLayer.videoGravity = .resizeAspect
playerLayer.frame = view.bounds
self.view.layer.addSublayer(playerLayer)
``` 

### 2 - init  ###

```swift   
MLYDriver.deactivate()
var options: MLYDriverOptions {
    let options = MLYDriverOptions()
    options.client.id = "input id"
    options.client.key = "input key"
    return options
}
do {
    try MLYDriver.initialize(options: options)
} catch {
    print(error)
}
```
 
### 3  ###

```swift  
MLYAVPlayerPlugin.adapt(playerLayer: playerLayer)
``` 

### playVideo  ###

```swift 
func playVideo() {
    do {
        let url = try ProxyURLModifier.replace(media url)
        playerItem = AVPlayerItem(url: url)
        playerItem?.preferredForwardBufferDuration = 15
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    } catch {
        print(error)
    }
}
```

## Author

119390052, benson@letron.tech

## License

MLYSDK is available under the MIT license. See the LICENSE file for more info.
