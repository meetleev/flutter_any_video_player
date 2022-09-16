# any_video_player
[![Pub](https://img.shields.io/pub/v/any_video_player.svg?style=flat-square)](https://pub.dev/packages/any_video_player)
[![support](https://img.shields.io/badge/platform-android%20|%20ios%20-blue.svg)](https://pub.dev/packages/any_video_player)

The video_player plugin gives low level access for the video playback. Advanced video player based on video_player and Chewie.


## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  any_video_player: <latest_version>
```
## Features

* support video player event.
* When the video width is larger than the screen width, the bottom progress bar is automatically aligned to the height of the video after scaling.

## Usage

```dart
AnyVideoPlayerController anyVideoPlayerController = AnyVideoPlayerController(
            dataSource: VideoPlayerDataSource.network('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
            controlsConf: ControlsConfiguration(paddingBottom: 10))

final playerWidget = AnyVideoPlayer(
  controller: anyVideoPlayerController,
);
```

Please make sure to dispose both controller widgets after use. For example by overriding the dispose method of the a `StatefulWidget`:
```dart
@override
void dispose() {
  anyVideoPlayerController.dispose();
  super.dispose();
}
```
