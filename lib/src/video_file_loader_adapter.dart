import 'package:video_player/video_player.dart';

import '../any_video_player.dart';

// A placeholder function to be implemented differently for web and non-web
VideoPlayerController getVideoPlayerControllerFromFile(
  VideoPlayerDataSource dataSource,
) {
  throw UnsupportedError('Must be implemented in platform-specific files.');
}
