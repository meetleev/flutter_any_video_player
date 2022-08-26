import 'package:flutter/material.dart';
import 'dart:async';

import 'package:any_video_player/any_video_player.dart';
import 'package:any_video_player/src/widget/center_play_button.dart';
import 'package:any_video_player/src/video_player_notifier.dart';
import 'package:any_video_player/src/video_progress_colors.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../utils.dart';
import 'progress_bar_adapter.dart';

class MaterialControls extends StatefulWidget {

  const MaterialControls({super.key});

  @override
  State<MaterialControls> createState() => MaterialControlsState();
}

class MaterialControlsState extends State<MaterialControls> {
  final barHeight = 48.0 * 1.5;
  AnyVideoPlayerController? _anyVPController;

  AnyVideoPlayerController get anyVPController => _anyVPController!;
  VideoPlayerController? _controller;

  VideoPlayerController get controller => _controller!;
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
    final videoSize = anyVPController.videoPlayerController.value.size;
    final offset = calculateVideo2ScreenHeightOffset(context, videoSize, mediaData: mediaData);
    var bottom = anyVPController.bottomBarConf.paddingBottom + offset / 2;
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
                  _buildBottomBar(),
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
    _controller = anyVPController.videoPlayerController;
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
        final bool isFinished = controller.value.position >= controller.value.duration;
        if (isFinished) notifier.hideControls = false;
      }
      setState(() {});
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildHitArea() {
    final bool isFinished = controller.value.position >= controller.value.duration;
    final bool showPlayButton = anyVPController.showPlayButton && !notifier.hideControls && !_dragging;
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
        isPlaying: controller.value.isPlaying,
        iconColor: Colors.white,
        isFinished: isFinished,
        backgroundColor: Colors.black54,
        show: showPlayButton,
        onPressed: _playPause,
      ),
    );
  }

  Widget _buildBottomBar() {
    final iconColor = Theme.of(context).textTheme.button!.color;
    return AnimatedOpacity(
      opacity: notifier.hideControls ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: anyVPController.bottomBarConf.materialBackgroundColor,
        height: barHeight,
        padding: const EdgeInsets.only(
          left: 20,
        ),
        child: SafeArea(
          bottom: anyVPController.isFullScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (anyVPController.isLive)
                    const Expanded(child: Text('LIVE'))
                  else
                    _buildPosition(iconColor),
                ],
              )),
              if (!anyVPController.isLive)
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    children: [_buildProgressBar()],
                  ),
                ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosition(Color? iconColor) {
    final position = controller.value.position;
    final duration = controller.value.duration;
    return RichText(
        text: TextSpan(
      text: '${formatDuration(position)} ',
      children: [
        TextSpan(
          text: '/ ${formatDuration(duration)}',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.white.withOpacity(.75),
            fontWeight: FontWeight.normal,
          ),
        )
      ],
      style: const TextStyle(
        fontSize: 14.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ));
  }

  Widget _buildProgressBar() {
    return Expanded(
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
      colors: anyVPController.bottomBarConf.materialProgressColors ??
          AnyVideoProgressColors(
            playedColor: Theme.of(context).colorScheme.secondary,
            handleColor: Theme.of(context).colorScheme.secondary,
            bufferedColor: Theme.of(context).backgroundColor.withOpacity(0.5),
            backgroundColor: Theme.of(context).disabledColor.withOpacity(.5),
          ),
    ));
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
          final isFinished = controller.value.position >= controller.value.duration;
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