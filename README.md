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

### 2 - initialize  MLYDriver ###

```swift 
do {
    try MLYDriver.initialize { options in
        options.client.id = client_id 
    }
} catch {
    print(error)
}
```

### 3 - plugin  ###

```swift    
var plugin: MLYAVPlayerPlugin = .init()

self.plugin.adapt(self.playerViewController)
```


### 4 - Play Video  ###

```swift 
func playVideo() {
    let url = URL(string: play_m3u8)!

    Task {
        await MLYDriver.ready()
        let playerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: playerItem)
        self.player.play()
    }
}
```

## License

MLYSDK is available under the MIT license. See the LICENSE file for more info.
