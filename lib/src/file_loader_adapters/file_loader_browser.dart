import 'package:video_player/video_player.dart';

import '../../any_video_player.dart';

VideoPlayerController getVideoPlayerControllerFromFile(
  VideoPlayerDataSource dataSource,
) {
  // **CRITICAL:** On web, File() is not available.
  throw UnsupportedError(
    'Direct file path access is not supported on web. '
    'Use an Asset or Network URL source.',
  );
}
