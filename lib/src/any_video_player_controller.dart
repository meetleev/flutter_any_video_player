import 'dart:async';
import 'dart:io';

import 'package:any_video_player/src/widget/material_controls.dart';
import 'package:any_video_player/src/widget/cupertino_controls.dart';
import 'package:flutter/material.dart';
import 'package:media_data_extractor/media_data_extractor.dart';
import 'package:video_player/video_player.dart';

import 'configuration/controls_configuration.dart';
import 'configuration/video_player_data_source.dart';
import 'constants.dart';
import 'events/any_video_player_event.dart';
import 'events/any_video_player_event_type.dart';

const _defaultHideControlsTimer = Duration(seconds: 3);
const List<double> _defaultPlaybackSpeeds = [
  0.25,
  0.5,
  0.75,
  1.0,
  1.25,
  1.5,
  1.75,
  2,
  4,
  8,
  16
];

class AnyVideoPlayerValue {
  final bool frameByFrameEnabled;
  final VideoData? videoData;

  /// Flag used to store full screen mode state.
  final bool isFullScreen;

  AnyVideoPlayerValue(
      {this.frameByFrameEnabled = false,
      this.videoData,
      this.isFullScreen = false});

  AnyVideoPlayerValue copyWith(
      {bool? frameByFrameEnabled, VideoData? videoData, bool? isFullScreen}) {
    return AnyVideoPlayerValue(
        frameByFrameEnabled: frameByFrameEnabled ?? this.frameByFrameEnabled,
        videoData: videoData ?? this.videoData,
        isFullScreen: isFullScreen ?? this.isFullScreen);
  }
}

class AnyVideoPlayerController extends ValueNotifier<AnyVideoPlayerValue> {
  late VideoPlayerController videoPlayerController;

  final VideoPlayerDataSource dataSource;

  /// The placeholder is displayed underneath the Video before it is initialized or played.
  final Widget? placeholder;

  /// Whether or not to show the controls at all
  final bool showBottomControls;

  /// Whether or not to show the playButton at all
  final bool showPlayButton;


  /// playback speeds
  final List<double> playbackSpeeds;

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

  MediaDataExtractor? _mediaDataExtractor;
  bool _isDisposed = false;

  AnyVideoPlayerController(
      {required this.dataSource,
      this.backgroundColor,
      this.placeholder,
      this.showBottomControls = true,
      this.showPlayButton = true,
      this.playbackSpeeds = _defaultPlaybackSpeeds,
      this.customControls,
      this.isLive = false,
      bool isAutoInitialize = true,
      bool isAutoPlay = false,
      bool frameByFrameEnabled = false,
      bool isLoop = false,
      this.hideControlsTimer = _defaultHideControlsTimer,
      ControlsConfiguration? controlsConf})
      : controlsConfiguration = controlsConf ?? ControlsConfiguration(),
        super(AnyVideoPlayerValue(frameByFrameEnabled: frameByFrameEnabled)) {
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
    if (isAutoInitialize || isAutoPlay) {
      initialize().then((_) {
        if (isLoop) {
          setLooping(isLoop);
        }
        if (isAutoPlay) {
          play();
        }
      });
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
    if (_isDisposed) {
      return;
    }
    if (!_streamController.isClosed) {
      _streamController.add(event);
    }
  }

  /// Listen on the given [listener].
  StreamSubscription<AnyVideoPlayerEvent> addPlayerEventListener(
      AnyVideoPlayerEventListener listener) {
    return on<AnyVideoPlayerEvent>().listen(listener);
  }

  bool get isFrameByFrameEnabled => value.frameByFrameEnabled;

  Future<void> setFrameByFrameEnabled(bool enabled) async {
    if (enabled != isFrameByFrameEnabled) {
      await pause();
      if (!enabled) {
        await setPlayBackSpeed(1);
      }
      if (null == value.videoData) {
        await fetchVideoMetaData();
      }
      value = value.copyWith(frameByFrameEnabled: enabled);
    }
  }

  double? get frameRate {
    final videoData = value.videoData;
    if (null != videoData && videoData.tracks.isNotEmpty) {
      return videoData.tracks.first?.frameRate ?? 1;
    }
    return null;
  }

  VideoData? get videoData => value.videoData;

  bool get isFullScreen => value.isFullScreen;

  void toggleFullScreen() {
    emit(AnyVideoPlayerEvent(
        eventType: AnyVideoPlayerEventType.fullScreenChange,
        data: !isFullScreen));
  }

  void onEnterFullScreen() {
    value = value.copyWith(isFullScreen: true);
  }

  void onExitFullScreen() {
    value = value.copyWith(isFullScreen: false);
  }

  Future<void> play() async {
    if (videoPlayerController.value.isInitialized) {
      if (isFrameByFrameEnabled) {
        videoPlayerController.setPlaybackSpeed(1 / (frameRate ?? 1));
      }
      await videoPlayerController.play();
      emit(AnyVideoPlayerEvent(eventType: AnyVideoPlayerEventType.play));
    }
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

  Future<void> setPlayBackSpeed(double speed) {
    return videoPlayerController.setPlaybackSpeed(speed);
  }

  double get playBackSpeed => videoPlayerController.value.playbackSpeed;

  Duration get position => videoPlayerController.value.position;

  Future<void> jumpPreviousFrame() async {
    if (isFrameByFrameEnabled) {
      final int delta = 1000 ~/ frameRate!;
      await seekTo(position - Duration(milliseconds: delta));
    }
  }

  Future<void> jumpNextFrame() async {
    if (isFrameByFrameEnabled) {
      final int delta = 1000 ~/ frameRate!;
      await seekTo(position + Duration(milliseconds: delta));
    }
  }

  Future<void> setLooping(bool loop) async {
    await videoPlayerController.setLooping(loop);
  }

  Future<void> initialize() async {
    if (isFrameByFrameEnabled) {
      await fetchVideoMetaData();
    }
    await videoPlayerController.initialize();
    emit(AnyVideoPlayerEvent(eventType: AnyVideoPlayerEventType.initialized));
  }

  Future<void> fetchVideoMetaData() async {
    _mediaDataExtractor ??= MediaDataExtractor();
    final dataType = MediaDataSourceType.values[dataSource.type.index];
    VideoData videoData = await _mediaDataExtractor!
        .getVideoData(MediaDataSource(type: dataType, url: dataSource.url));
    value = value.copyWith(videoData: videoData);
  }

  @override
  void dispose() async {
    if (_isDisposed) {
      return;
    }
    await _streamController.close();
    await videoPlayerController.dispose();
    _isDisposed = true;

    super.dispose();
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
