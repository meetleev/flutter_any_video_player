import 'package:video_player/video_player.dart';

enum VideoPlayerDataSourceType {
  /// The video was included in the app's asset files.
  asset,

  /// The video was downloaded from the internet.
  network,

  /// The video was loaded off of the local filesystem.
  // file,

  /// The video was loaded off of the memory.
  // memory,

  /// The video is available via contentUri. Android only.
  // contentUri,
}

class VideoPlayerDataSource {
  ///Type of source of video
  final VideoPlayerDataSourceType type;

  ///Url of the video
  final String url;

  /// Custom headers for player
  final Map<String, String> headers;

  /// **Android only**. Will override the platform's generic file format
  /// detection with whatever is set here.
  final VideoFormat? videoFormat;

  /// Provide additional configuration options (optional). Like setting the audio mode to mix
  final VideoPlayerOptions? videoPlayerOptions;
  Future<ClosedCaptionFile>? closedCaptionFile;

  /// Only set for [asset] videos. The package that the asset was loaded from.
  final String? package;

  VideoPlayerDataSource(
    this.type,
    this.url, {
    this.package,
    this.headers = const {},
    this.videoFormat,
    this.videoPlayerOptions,
    this.closedCaptionFile,
  });

  VideoPlayerDataSource.network(
    this.url, {
    this.videoFormat,
    this.headers = const {},
    this.videoPlayerOptions,
    this.closedCaptionFile,
  })  : type = VideoPlayerDataSourceType.network,
        package = null;

  VideoPlayerDataSource.asset(
    this.url, {
    this.package,
    this.videoPlayerOptions,
    this.closedCaptionFile,
  })  : type = VideoPlayerDataSourceType.asset,
        videoFormat = null,
        headers = const {};
}
