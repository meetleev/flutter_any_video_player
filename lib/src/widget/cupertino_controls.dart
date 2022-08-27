import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:any_video_player/src/video_progress_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../any_video_player.dart';
import '../utils.dart';
import '../video_player_notifier.dart';
import 'progress_bar_adapter.dart';
import 'center_play_button.dart';

class CupertinoControls extends StatefulWidget {
  const CupertinoControls({Key? key}) : super(key: key);

  @override
  State<CupertinoControls> createState() => CupertinoControlsState();
}

class CupertinoControlsState extends State<CupertinoControls> {
  final marginSize = 5.0;

  AnyVideoPlayerController? _anyVPController;

  AnyVideoPlayerController get anyVPController => _anyVPController!;

  VideoPlayerController get controller => anyVPController.videoPlayerController;

  ControlsConfiguration get controlsConf =>
      anyVPController.controlsConfiguration;

  bool _wasLoading = false;
  late VideoPlayerNotifier notifier;
  Timer? _hideControlsTimer;
  bool _displayTapped = false;
  bool _dragging = false;

  @override
  void initState() {
    notifier = Provider.of<VideoPlayerNotifier>(context, listen: false);
    super.initState();
  }

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
    return GestureDetector(
      onTap: () => _restartControlsTimer(),
      child: AbsorbPointer(
        absorbing: notifier.hideControls,
        child: Stack(
          children: [
            _wasLoading
                ? Center(
                    child: _buildLoading(),
                  )
                : _buildHitArea(),
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

  @override
  void didChangeDependencies() {
    final oldAnyVideoPlayerController = _anyVPController;
    _anyVPController = AnyVideoPlayerController.of(context);
    if (oldAnyVideoPlayerController != _anyVPController) {
      _dispose();
      _initialize();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    controller.addListener(_updateState);
    _updateState();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideControlsTimer?.cancel();
  }

  void _updateState() {
    if (mounted) {
      _wasLoading = controller.value.isBuffering;
      if (controller.value.isInitialized) {
        final bool isFinished =
            controller.value.position >= controller.value.duration;
        if (isFinished) notifier.hideControls = false;
      }
      setState(() {});
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget _buildHitArea() {
    final bool isFinished =
        controller.value.position >= controller.value.duration;
    final bool showPlayButton = anyVPController.showPlayButton &&
        !controller.value.isPlaying &&
        !_dragging;

    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          if (_displayTapped) {
            setState(() {
              notifier.hideControls = true;
            });
          } else {
            _restartControlsTimer();
          }
        } else {
          _playPause();
          setState(() {
            notifier.hideControls = true;
          });
        }
      },
      child: CenterPlayButton(
        backgroundColor: controlsConf.cupertinoBackgroundColor,
        iconColor: controlsConf.cupertinoIconColor,
        isFinished: isFinished,
        isPlaying: controller.value.isPlaying,
        show: showPlayButton,
        onPressed: _playPause,
      ),
    );
  }

  Widget _buildBottomBar(double barHeight) {
    final iconColor = controlsConf.cupertinoIconColor;
    return SafeArea(
        bottom: anyVPController.isFullScreen,
        child: AnimatedOpacity(
          opacity: notifier.hideControls ? 0 : 1,
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
        child: VideoProgressBarAdapter(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideControlsTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideControlsTimer();
          },
          colors: controlsConf.cupertinoProgressColors ??
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
      onTap: _playPause,
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
      onTap: () {
        _restartControlsTimer();
        final beginning = Duration.zero.inMilliseconds;
        final skip = (controller.value.position - const Duration(seconds: 15))
            .inMilliseconds;
        controller.seekTo(Duration(milliseconds: max(skip, beginning)));
      },
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
      onTap: () {
        _restartControlsTimer();
        final end = controller.value.duration.inMilliseconds;
        final skip = (controller.value.position + const Duration(seconds: 15))
            .inMilliseconds;
        controller.seekTo(Duration(milliseconds: min(skip, end)));
      },
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

  void _playPause() {
    setState(() {
      if (controller.value.isPlaying) {
        notifier.hideControls = false;
        _hideControlsTimer?.cancel();
        controller.pause();
      } else {
        _restartControlsTimer();
        if (!controller.value.isInitialized) {
          controller.initialize().then((value) => controller.play());
        } else {
          final isFinished =
              controller.value.position >= controller.value.duration;
          if (isFinished) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
        }
      }
    });
  }

  void _restartControlsTimer() {
    _hideControlsTimer?.cancel();
    _startHideControlsTimer();
    setState(() {
      notifier.hideControls = false;
      _displayTapped = true;
    });
  }

  void _startHideControlsTimer() {
    final hideControlsTimer = anyVPController.hideControlsTimer.isNegative
        ? AnyVideoPlayerController.defaultHideControlsTimer
        : anyVPController.hideControlsTimer;
    _hideControlsTimer = Timer(hideControlsTimer, () {
      setState(() {
        notifier.hideControls = true;
      });
    });
  }
}
