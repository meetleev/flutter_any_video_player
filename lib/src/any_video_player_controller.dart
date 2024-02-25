import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../any_video_player.dart';
import 'constants.dart';

const _defaultHideControlsTimer = Duration(seconds: 3);

class AnyVideoPlayerController {
  late VideoPlayerController videoPlayerController;

  final VideoPlayerDataSource dataSource;

  /// The placeholder is displayed underneath the Video before it is initialized or played.
  final Widget? placeholder;

  /// Flag used to store full screen mode state.
  final bool _isFullScreen = false;

  /// Flag used to store full screen mode state.
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

  final StreamController _streamController = StreamController.broadcast();

  AnyVideoPlayerController(
      {required this.dataSource,
      this.backgroundColor,
      this.placeholder,
      this.showControls = true,
      this.showPlayButton = true,
      this.customControls,
      this.isLive = false,
      bool isAutoInitialize = true,
      this.hideControlsTimer = _defaultHideControlsTimer,
      ControlsConfiguration? controlsConf})
      : controlsConfiguration = controlsConf ?? ControlsConfiguration() {
    switch (dataSource.type) {
      case VideoPlayerDataSourceType.network:
        videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(dataSource.url),
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
                exception: 'file does not exists!',
                library: Constants.libraryName));
          }
        } catch (e, s) {
          FlutterError.presentError(FlutterErrorDetails(
              exception: e, stack: s, library: Constants.libraryName));
        }
        break;
    }
    if (isAutoInitialize) {
      initialize();
    }
  }

  Stream<T> on<T>() {
    if (dynamic == T) {
      return _streamController.stream as Stream<T>;
    }
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  /// emit event
  void emit<T>(T event) {
    _streamController.add(event);
  }

  /// Listen on the given [listener].
  StreamSubscription<AnyVideoPlayerEvent> addPlayerEventListener(
      AnyVideoPlayerEventListener listener) {
    return on<AnyVideoPlayerEvent>().listen(listener);
  }

  Future<void> play() async {
    await videoPlayerController.play();
    emit(AnyVideoPlayerEvent(eventType: AnyVideoPlayerEventType.play));
  }

  Future<void> pause() async {
    await videoPlayerController.pause();
    emit(AnyVideoPlayerEvent(eventType: AnyVideoPlayerEventType.pause));
  }

  Future<void> seekTo(Duration position) async {
    await videoPlayerController.seekTo(position);
    emit(AnyVideoPlayerEvent(
        eventType: AnyVideoPlayerEventType.seekTo, data: position));
  }

  Future<void> setLooping(bool loop) async {
    await videoPlayerController.setLooping(loop);
  }

  Future<void> initialize() async {
    await videoPlayerController.initialize();
    emit(AnyVideoPlayerEvent(eventType: AnyVideoPlayerEventType.initialized));
  }

  dispose() {
    _streamController.close();
    videoPlayerController.dispose();
  }

  static AnyVideoPlayerController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<
        AnyVideoPlayerControllerProvider>()!;
    return provider.controller;
  }
}

class AnyVideoPlayerControllerProvider extends InheritedWidget {
  final AnyVideoPlayerController controller;

  const AnyVideoPlayerControllerProvider(
      {super.key, required super.child, required this.controller});

  @override
  bool updateShouldNotify(AnyVideoPlayerControllerProvider oldWidget) =>
      oldWidget.controller != controller;
}
