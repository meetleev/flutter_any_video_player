import 'dart:ui';
import 'package:flutter/cupertino.dart';

import '../utils.dart';
import '../video_progress_colors.dart';
import 'center_play_button.dart';
import 'controls_state.dart';

class CupertinoControls extends StatefulWidget {
  const CupertinoControls({super.key});

  @override
  State<CupertinoControls> createState() => _CupertinoControlsState();
}

class _CupertinoControlsState extends ControlsState<CupertinoControls> {
  final marginSize = 5.0;

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final orientation = mediaData.orientation;
    final barHeight = orientation == Orientation.portrait ? 26.0 : 47.0;
    final controls = Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (wasLoading) _buildLoading(),
        Positioned(
          left: 0,
          right: 0,
          bottom: controlsConf.paddingBottom + barHeight,
          top: 0,
          child: buildHitArea(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: controlsConf.paddingBottom,
          child: SizedBox(
            height: barHeight,
            child: _buildBottomBar(barHeight),
          ),
        ),
      ],
    );
    return buildMain(
        child: AbsorbPointer(
            absorbing: !controlsVisible,
            child: anyVPController.isFullScreen
                ? SafeArea(child: controls)
                : controls));
  }

  Widget _buildLoading() {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget _buildBottomBar(double barHeight) {
    final iconColor = controlsConf.cupertinoIconColor;
    return AnimatedOpacity(
        opacity: !controlsVisible ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: marginSize),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                  height: barHeight,
                  color: controlsConf.cupertinoBackgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: anyVPController.isLive
                      ? Row(children: [
                          _buildLive(iconColor),
                        ])
                      : Row(
                          children: [
                            _buildSkipBack(iconColor),
                            _buildPlayPause(iconColor),
                            _buildSkipForward(iconColor),
                            _buildPosition(iconColor),
                            _buildProgressBar(),
                            _buildRemaining(iconColor)
                          ],
                        )),
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
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
    return Text(formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ));
  }

  Widget _buildRemaining(Color? iconColor) {
    final position = controller.value.duration - controller.value.position;
    return Text('-${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0));
  }

  GestureDetector _buildPlayPause(Color iconColor) {
    return GestureDetector(
      onTap: playPause,
      child: Container(
        margin: const EdgeInsets.only(
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

  GestureDetector _buildSkipBack(Color iconColor) {
    return GestureDetector(
      onTap: skipBack,
      child: Icon(
        CupertinoIcons.gobackward_15,
        color: iconColor,
        size: 18.0,
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor) {
    return GestureDetector(
      onTap: skipForward,
      child: Container(
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
