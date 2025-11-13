# any_video_player
[![Pub](https://img.shields.io/pub/v/any_video_player.svg?style=flat-square)](https://pub.dev/packages/any_video_player)
[![support](https://img.shields.io/badge/platform-android%20|%20MacOS%20|%20ios%20-blue.svg)](https://pub.dev/packages/any_video_player)

The video_player plugin gives low level access for the video playback. Advanced video player based on video_player.


## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  any_video_player: <latest_version>
```
## Features

* support video player event.
* support frame by frame mode
* support fullscreen mode
* support set playbackSpeed
* When the video width is larger than the screen width, the bottom progress bar is automatically aligned to the height of the video after scaling.

## Usage

```dart
AnyVideoPlayerController anyVideoPlayerController = AnyVideoPlayerController(
            dataSource: VideoPlayerDataSource.network('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'));

final playerWidget = AnyVideoPlayer(
  controller: anyVideoPlayerController,
);
```
