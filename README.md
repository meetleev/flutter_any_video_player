# any_video_player
[![Pub](https://img.shields.io/pub/v/any_video_player.svg?style=flat-square)](https://pub.dev/packages/any_video_player)
[![support](https://img.shields.io/badge/platform-android%20|%20ios%20-blue.svg)](https://pub.dev/packages/any_video_player)

The video_player plugin gives low level access for the video playback. Advanced video player based on video_player and Chewie.


## Installation

In your `pubspec.yaml` file within your Flutter Project: 

```yaml
dependencies:
  any_video_player: <latest_version>
```

## Usage

```dart
import 'package:chewie/chewie.dart';
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
  anyVideoPlayerController.disposeAll();
  super.dispose();
}
```
