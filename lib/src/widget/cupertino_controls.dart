import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  Orientation _orientation = Orientation.portrait;

  double get progressBarHeight =>
      _orientation == Orientation.portrait ? 26.0 : 47.0;

  double get bottomActionsHeight =>
      _orientation == Orientation.portrait ? 80 : 47.0;
  Size _screenSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    _screenSize = mediaData.size;
    _orientation = mediaData.orientation;
    final controls = Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (wasLoading) _buildLoading(),
        Positioned.fill(
          // bottom: controlsConf.paddingBottom + bottomActionsHeight,
          child: buildHitArea(),
        ),
        if (anyVPController.showBottomControls)
          Positioned(
            left: 0,
            right: 0,
            bottom: controlsConf.paddingBottom,
            child: SizedBox(
              height: bottomActionsHeight,
              child: _buildBottomActions(),
            ),
          ),
      ],
    );
    return buildMain(
      child: AbsorbPointer(
        absorbing: !controlsVisible,
        child: anyVPController.isFullScreen
            ? SafeArea(child: controls)
            : controls,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CupertinoActivityIndicator());
  }

  Widget _buildBottomActions() {
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
              height: bottomActionsHeight,
              color: controlsConf.cupertinoBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _orientation == Orientation.portrait
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSkipBack(size: 24),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: _buildPlayPause(scale: 2),
                                  ),
                                  _buildSkipForward(size: 24),
                                ],
                              ),
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buildFullScreen(),
                                    const SizedBox(width: 10),
                                    _buildMoreOptions(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: progressBarHeight,
                            child: Row(
                              children: [
                                _buildPosition(),
                                _buildProgressBar(),
                                _buildRemaining(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        _buildSkipBack(),
                        Container(
                          margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                          child: _buildPlayPause(),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: _buildSkipForward(),
                        ),
                        _buildPosition(),
                        _buildProgressBar(),
                        _buildRemaining(),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildFullScreen(),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /*Widget _buildLive(Color? iconColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        'LIVE',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }*/

  Widget _buildProgressBar() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: buildVideoProgressBarAdapter(
          color:
              controlsConf.cupertinoProgressColors ??
              AnyVideoProgressColors(
                playedColor: const Color.fromARGB(120, 255, 255, 255),
                handleColor: const Color.fromARGB(255, 255, 255, 255),
                bufferedColor: const Color.fromARGB(60, 255, 255, 255),
                backgroundColor: const Color.fromARGB(20, 255, 255, 255),
              ),
        ),
      ),
    );
  }

  Widget _buildPosition() {
    final position = controller.value.position;
    return Text(
      formatDuration(position),
      style: TextStyle(color: controlsConf.cupertinoIconColor, fontSize: 12.0),
    );
  }

  Widget _buildRemaining() {
    final position = controller.value.duration - controller.value.position;
    return Text(
      '-${formatDuration(position)}',
      style: TextStyle(color: controlsConf.cupertinoIconColor, fontSize: 12.0),
    );
  }

  GestureDetector _buildPlayPause({double scale = 1}) {
    return GestureDetector(
      onTap: playPause,
      child: AnimatedPlayPause(
        color: controlsConf.cupertinoIconColor,
        playing: controller.value.isPlaying,
        scale: scale,
      ),
    );
  }

  Widget _buildSkipBack({double size = 18}) {
    return GestureDetector(
      onTap: anyVPController.isFrameByFrameEnabled
          ? anyVPController.jumpPreviousFrame
          : skipBack,
      child: Icon(
        anyVPController.isFrameByFrameEnabled
            ? CupertinoIcons.gobackward
            : CupertinoIcons.gobackward_15,
        color: controlsConf.cupertinoIconColor,
        size: size,
      ),
    );
  }

  GestureDetector _buildSkipForward({double size = 18}) {
    return GestureDetector(
      onTap: anyVPController.isFrameByFrameEnabled
          ? anyVPController.jumpNextFrame
          : skipForward,
      child: Icon(
        anyVPController.isFrameByFrameEnabled
            ? CupertinoIcons.goforward
            : CupertinoIcons.goforward_15,
        color: controlsConf.cupertinoIconColor,
        size: size,
      ),
    );
  }

  Widget _buildFullScreen() {
    return GestureDetector(
      onTap: () => anyVPController.toggleFullScreen(),
      child: Icon(
        anyVPController.isFullScreen
            ? CupertinoIcons.arrow_down_right_arrow_up_left
            : CupertinoIcons.arrow_up_left_arrow_down_right,
        color: controlsConf.cupertinoIconColor,
      ),
    );
  }

  Widget _buildMoreOptions() {
    return GestureDetector(
      onTap: _onShowMore,
      child: Icon(
        CupertinoIcons.ellipsis_circle,
        color: controlsConf.cupertinoIconColor,
      ),
    );
  }

  void _onShowMore() {
    List<Widget> children = [];
    if (!anyVPController.isFrameByFrameEnabled) {
      children.add(
        buildPlaybackSpeedOption(
          onPressed: () {
            Navigator.of(context).pop();
            _showModalBottomSheet(buildSpeedOptions());
          },
        ),
      );
      children.add(const Divider());
    }
    children.add(buildFrameByFrameOption());
    _showModalBottomSheet(children);
  }

  void _showModalBottomSheet(List<Widget> children) {
    children.insert(0, const SizedBox(height: 12));
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints.tightFor(width: _screenSize.width * 0.96),
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
