import 'package:flutter/material.dart';

import '../any_video_player_controller.dart';
import '../video_progress_colors.dart';
import 'video_progress_bar.dart';

class VideoProgressBarAdapter extends StatelessWidget {
  VideoProgressBarAdapter(
    this.controller, {
    AnyVideoProgressColors? colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    super.key,
  }) : colors = colors ?? AnyVideoProgressColors();

  final AnyVideoPlayerController controller;
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
