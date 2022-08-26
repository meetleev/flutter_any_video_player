import 'package:any_video_player/src/widget/video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../video_progress_colors.dart';

class VideoProgressBarAdapter extends StatelessWidget {
  VideoProgressBarAdapter(
    this.controller, {
    AnyVideoProgressColors? colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    Key? key,
  })  : colors = colors ?? AnyVideoProgressColors(),
        super(key: key);

  final VideoPlayerController controller;
  final AnyVideoProgressColors colors;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;

  @override
  Widget build(BuildContext context) {
    double barHeight = 5;
    double handleHeight = 6;
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        barHeight = 10;
        handleHeight = 6;
        break;
      case TargetPlatform.fuchsia:
        // TODO: Handle this case.
        break;
      case TargetPlatform.iOS:
        barHeight = 5;
        handleHeight = 6;
        break;
      case TargetPlatform.linux:
        // TODO: Handle this case.
        break;
      case TargetPlatform.macOS:
        // TODO: Handle this case.
        break;
      case TargetPlatform.windows:
        // TODO: Handle this case.
        break;
    }
    return AnyVideoProgressBar(
      controller,
      barHeight: barHeight,
      handleHeight: handleHeight,
      drawShadow: true,
      colors: colors,
      onDragEnd: onDragEnd,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
    );
  }
}
