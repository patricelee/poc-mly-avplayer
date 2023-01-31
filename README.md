# poc-mly-avplayer 

[![Language](https://img.shields.io/badge/Swift-5.0-green.svg?style=flat)](http://cocoapods.org/pods/MLYSDK) 
[![Version](https://img.shields.io/badge/version-0.1.2-blue)](https://github.com/patricelee/poc-mly-avplayer/releases/tag/0.1.2) 

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
self.player = .init()
self.playerViewController = .init()

self.playerViewController.showsPlaybackControls = true
self.playerViewController.player = self.player
self.addChild(self.playerViewController)
self.view.addSubview(self.playerViewController.view)
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
        let url = try ProxyURLModifier.replace("media url")
        playerItem = AVPlayerItem(url: url)
        playerItem?.preferredForwardBufferDuration = 15
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    } catch {
        print(error)
    }
}
```

## License

MLYSDK is available under the MIT license. See the LICENSE file for more info.
