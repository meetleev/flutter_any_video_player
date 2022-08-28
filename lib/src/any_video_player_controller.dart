import 'dart:io';

import 'package:any_video_player/src/constants.dart';
import 'package:any_video_player/src/event/any_video_player_event_type.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../any_video_player.dart';
import 'event/any_video_player_event.dart';

class AnyVideoPlayerController {
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

  /// The controlsConfiguration to use for the Material Progress Bar.
  final ControlsConfiguration controlsConfiguration;

  /// Color of the background, when no frame is displayed.
  final Color? backgroundColor;

  final EventManager _eventManager = EventManager.instance;

  AnyVideoPlayerController(
      {Key? key,
      required this.dataSource,
      this.backgroundColor,
      this.placeholder,
      this.showControls = true,
      this.showPlayButton = true,
      this.customControls,
      this.isLive = false,
      this.hideControlsTimer = defaultHideControlsTimer,
      ControlsConfiguration? controlsConf})
      : controlsConfiguration = controlsConf ?? ControlsConfiguration() {
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
      case VideoPlayerDataSourceType.file:
        try {
          var file = File(dataSource.url);
          if (file.existsSync()) {
            videoPlayerController = VideoPlayerController.file(file,
                videoPlayerOptions: dataSource.videoPlayerOptions,
                closedCaptionFile: dataSource.closedCaptionFile);
          } else {
            FlutterError.presentError(const FlutterErrorDetails(
                exception: 'file does not exists!', library: Constants.libraryName));
          }
        } catch (e, s) {
          FlutterError.presentError(
              FlutterErrorDetails(exception: e, stack: s, library: Constants.libraryName));
        }
        break;
    }
    initializeVideo();
  }

  dispose() {
    videoPlayerController.dispose();
  }

  /// Listen on the given [listener].
  void addEventListener(AnyVideoPlayerEventListener listener) => _eventManager.addEventListener(listener);

  /// Remove the given [listener].
  void removeEventListener(AnyVideoPlayerEventListener listener) =>
      _eventManager.removeEventListener(listener);

  Future<void> play() async {
    await videoPlayerController.play();
    _eventManager.postEvent(AnyVideoPlayerEventType.play);
  }

  Future<void> pause() async {
    await videoPlayerController.pause();
    _eventManager.postEvent(AnyVideoPlayerEventType.pause);
  }

  Future<void> seekTo(Duration position) async {
    await videoPlayerController.seekTo(position);
    _eventManager.postEvent(AnyVideoPlayerEventType.seekTo, params: position);
  }

  Future<void> initializeVideo() async {
    await videoPlayerController.initialize();
    _eventManager.postEvent(AnyVideoPlayerEventType.initialized);
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
