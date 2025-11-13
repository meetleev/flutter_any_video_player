import 'dart:io' show File;

import 'package:video_player/video_player.dart';

import '../../any_video_player.dart';

VideoPlayerController getVideoPlayerControllerFromFile(
  VideoPlayerDataSource dataSource,
) {
  try {
    var file = File(dataSource.url);
    if (file.existsSync()) {
      return VideoPlayerController.file(
        file,
        videoPlayerOptions: dataSource.videoPlayerOptions,
        closedCaptionFile: dataSource.closedCaptionFile,
      );
    } else {
      throw 'file does not exists!';
    }
  } catch (e) {
    rethrow;
  }
}
