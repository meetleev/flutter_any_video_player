import 'package:flutter/cupertino.dart';

String formatBitrate(int bitrate) {
  if (bitrate < 1000) {
    return "$bitrate bit/s";
  }
  if (bitrate < 1000000) {
    final kBit = (bitrate / 1000).floor();
    return "~$kBit KBit/s";
  }
  final mBit = (bitrate / 1000000).floor();
  return "~$mBit MBit/s";
}

String formatDuration(Duration position) {
  final ms = position.inMilliseconds;

  int seconds = ms ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  final minutes = seconds ~/ 60;
  seconds = seconds % 60;

  final hoursString =
      hours >= 10
          ? '$hours'
          : hours == 0
          ? '00'
          : '0$hours';

  final minutesString =
      minutes >= 10
          ? '$minutes'
          : minutes == 0
          ? '00'
          : '0$minutes';

  final secondsString =
      seconds >= 10
          ? '$seconds'
          : seconds == 0
          ? '00'
          : '0$seconds';

  final formattedTime =
      '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';

  return formattedTime;
}

double calculateAspectRatio(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final width = size.width;
  final height = size.height;

  return width > height ? width / height : height / width;
}

double calculateVideo2ScreenWidthRatio(
  BuildContext context,
  Size videoSize, {
  MediaQueryData? mediaData,
}) {
  if (videoSize.isEmpty) return 0;
  mediaData ??= MediaQuery.of(context);
  final orientation = mediaData.orientation;
  final width =
      orientation == Orientation.portrait
          ? mediaData.size.width
          : mediaData.size.height;
  return width * mediaData.devicePixelRatio / videoSize.width;
}
