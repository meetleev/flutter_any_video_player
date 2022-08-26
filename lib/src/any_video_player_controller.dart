import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../any_video_player.dart';

class AnyVideoPlayerController extends ChangeNotifier {
  static const defaultHideControlsTimer = Duration(seconds: 3);

  late VideoPlayerController videoPlayerController;

  final VideoPlayerDataSource dataSource;

  /// The placeholder is displayed underneath the Video before it is initialized or played.
  final Widget? placeholder;

  ///Flag used to store full screen mode state.
  bool _isFullScreen = false;

  ///Flag used to store full screen mode state.
  bool get isFullScreen => _isFullScreen;

  /// Whether or not to show the controls at all
  final bool showControls;

  /// Whether or not to show the playButton at all
  final bool showPlayButton;

  /// Defines customised controls. Check [MaterialControls] or
  /// [CupertinoControls] for reference.
  final Widget? customControls;

  /// Defines the [Duration] before the video controls are hidden. By default, this is set to three seconds.
  final Duration hideControlsTimer;

  /// Defines if the controls should be shown for live stream video
  final bool isLive;

  /// The progressBarConfiguration to use for the Material Progress Bar.
  final BottomBarConfiguration bottomBarConf;

  ///Color of the background, when no frame is displayed.
  final Color backgroundColor;

  AnyVideoPlayerController(
      {Key? key,
      required this.dataSource,
      this.backgroundColor = Colors.black,
      this.placeholder,
      this.showControls = true,
      this.showPlayButton = true,
      this.customControls,
      this.isLive = false,
      this.hideControlsTimer = defaultHideControlsTimer,
      BottomBarConfiguration? barConfiguration})
      : bottomBarConf = barConfiguration ?? BottomBarConfiguration() {
    switch (dataSource.type) {
      case VideoPlayerDataSourceType.network:
        videoPlayerController = VideoPlayerController.network(dataSource.url,
            videoPlayerOptions: dataSource.videoPlayerOptions,
            httpHeaders: dataSource.headers,
            closedCaptionFile: dataSource.closedCaptionFile,
            formatHint: dataSource.videoFormat);
        break;
      case VideoPlayerDataSourceType.asset:
        videoPlayerController = VideoPlayerController.asset(dataSource.url,
            package: dataSource.package,
            videoPlayerOptions: dataSource.videoPlayerOptions,
            closedCaptionFile: dataSource.closedCaptionFile);
        break;
    }
  }

  static AnyVideoPlayerController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AnyVideoPlayerControllerProvider>()!;
    return provider.controller;
  }
}

class AnyVideoPlayerControllerProvider extends InheritedWidget {
  final AnyVideoPlayerController controller;

  const AnyVideoPlayerControllerProvider({Key? key, required Widget child, required this.controller})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(AnyVideoPlayerControllerProvider oldWidget) => oldWidget.controller != controller;
}
