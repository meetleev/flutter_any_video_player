import 'dart:ui';
import 'package:any_video_player/src/video_progress_colors.dart';
import 'package:any_video_player/src/widget/controls_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'center_play_button.dart';

class CupertinoControls extends StatefulWidget {
  const CupertinoControls({super.key});

  @override
  State<CupertinoControls> createState() => CupertinoControlsState();
}

class CupertinoControlsState extends ControlsState<CupertinoControls> {
  final marginSize = 5.0;

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final orientation = mediaData.orientation;
    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;
    final videoSize = anyVPController.videoPlayerController.value.size;
    final offset = controlsConf.autoAlignVideoBottom
        ? calculateVideo2ScreenHeightOffset(context, videoSize,
            mediaData: mediaData)
        : 0;
    var bottom = controlsConf.paddingBottom + offset / 2;
    return buildMain(
      child: AbsorbPointer(
        absorbing: !controlsVisible,
        child: Stack(
          children: [
            wasLoading
                ? Center(
                    child: _buildLoading(),
                  )
                : buildHitArea(),
            Container(
              padding: EdgeInsets.only(bottom: bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBottomBar(barHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget _buildBottomBar(double barHeight) {
    final iconColor = controlsConf.cupertinoIconColor;
    return SafeArea(
        bottom: anyVPController.isFullScreen,
        child: AnimatedOpacity(
          opacity: !controlsVisible ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.all(marginSize),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                    height: barHeight,
                    color: controlsConf.cupertinoBackgroundColor,
                    child: anyVPController.isLive
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                _buildLive(iconColor),
                              ])
                        : Row(
                            children: [
                              _buildSkipBack(iconColor, barHeight),
                              _buildPlayPause(iconColor, barHeight),
                              _buildSkipForward(iconColor, barHeight),
                              _buildPosition(iconColor),
                              _buildProgressBar(),
                              _buildRemaining(iconColor)
                            ],
                          )),
              ),
            ),
          ),
        ));
  }

  Widget _buildLive(Color? iconColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        'LIVE',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: buildVideoProgressBarAdapter(
          color: controlsConf.cupertinoProgressColors ??
              AnyVideoProgressColors(
                playedColor: const Color.fromARGB(
                  120,
                  255,
                  255,
                  255,
                ),
                handleColor: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ),
                bufferedColor: const Color.fromARGB(
                  60,
                  255,
                  255,
                  255,
                ),
                backgroundColor: const Color.fromARGB(
                  20,
                  255,
                  255,
                  255,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildPosition(Color? iconColor) {
    final position = controller.value.position;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color? iconColor) {
    final position = controller.value.duration - controller.value.position;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        '-${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: AnimatedPlayPause(
          color: iconColor,
          playing: controller.value.isPlaying,
        ),
      ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: skipBack,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        margin: const EdgeInsets.only(left: 10.0),
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 6.0,
        ),
        child: Icon(
          CupertinoIcons.gobackward_15,
          color: iconColor,
          size: 18.0,
        ),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: skipForward,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ),
        margin: const EdgeInsets.only(
          right: 8.0,
        ),
        child: Icon(
          CupertinoIcons.goforward_15,
          color: iconColor,
          size: 18.0,
        ),
      ),
    );
  }
}
