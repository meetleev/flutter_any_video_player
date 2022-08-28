import 'dart:async';
import 'dart:math';

import 'package:any_video_player/src/event/any_video_player_event.dart';
import 'package:any_video_player/src/event/any_video_player_event_type.dart';
import 'package:any_video_player/src/widget/progress_bar_adapter.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import '../../any_video_player.dart';
import '../video_progress_colors.dart';
import 'center_play_button.dart';

abstract class ControlsState<T extends StatefulWidget> extends State<T> {
  AnyVideoPlayerController? _anyVPController;

  AnyVideoPlayerController get anyVPController => _anyVPController!;

  VideoPlayerController get controller => anyVPController.videoPlayerController;

  ControlsConfiguration get controlsConf => anyVPController.controlsConfiguration;

  bool wasLoading = false;
  Timer? _hideControlsTimer;
  bool _displayTapped = false;
  bool _dragging = false;
  bool controlsVisible = true;

  @override
  void initState() {
    super.initState();
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
      wasLoading = controller.value.isBuffering;
      if (controller.value.isInitialized) {
        final bool isFinished = controller.value.position >= controller.value.duration;
        if (isFinished) {
          EventManager.instance.postEvent(AnyVideoPlayerEventType.finished);
          changePlayerControlsVisible(true);
        }
      }
      setState(() {});
    }
  }

  void playPause() {
    setState(() {
      if (controller.value.isPlaying) {
        changePlayerControlsVisible(true);
        _hideControlsTimer?.cancel();
        anyVPController.pause();
      } else {
        _restartControlsTimer();
        if (!controller.value.isInitialized) {
          anyVPController.initializeVideo().then((value) => anyVPController.play());
        } else {
          final isFinished = controller.value.position >= controller.value.duration;
          if (isFinished) {
            anyVPController.seekTo(Duration.zero);
          }
          anyVPController.play();
        }
      }
    });
  }

  void _restartControlsTimer() {
    _hideControlsTimer?.cancel();
    _startHideControlsTimer();
    _displayTapped = true;
    changePlayerControlsVisible(true);
  }

  void _startHideControlsTimer() {
    final hideControlsTimer = anyVPController.hideControlsTimer.isNegative
        ? AnyVideoPlayerController.defaultHideControlsTimer
        : anyVPController.hideControlsTimer;
    _hideControlsTimer = Timer(hideControlsTimer, () {
      changePlayerControlsVisible(false);
    });
  }

  Widget buildMain({required Widget child}) {
    return GestureDetector(
      onTap:  _restartControlsTimer,
      child: child,
    );
  }

  Widget buildHitArea() {
    final bool isFinished = controller.value.position >= controller.value.duration;
    final bool showPlayButton = anyVPController.showPlayButton && !controller.value.isPlaying && !_dragging;

    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          if (_displayTapped) {
            changePlayerControlsVisible(false);
          } else {
            _restartControlsTimer();
          }
        } else {
          playPause();
          changePlayerControlsVisible(false);
        }
      },
      child: CenterPlayButton(
        backgroundColor: controlsConf.cupertinoBackgroundColor,
        iconColor: controlsConf.cupertinoIconColor,
        isFinished: isFinished,
        isPlaying: controller.value.isPlaying,
        show: showPlayButton,
        onPressed: playPause,
      ),
    );
  }

  Widget buildVideoProgressBarAdapter({AnyVideoProgressColors? color}) {
    return VideoProgressBarAdapter(
      anyVPController,
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
      colors: color,
    );
  }

  void skipForward() {
    _restartControlsTimer();
    final end = controller.value.duration.inMilliseconds;
    final skip = (controller.value.position + const Duration(seconds: 15)).inMilliseconds;
    anyVPController.seekTo(Duration(milliseconds: min(skip, end)));
  }

  void skipBack() {
    _restartControlsTimer();
    final beginning = Duration.zero.inMilliseconds;
    final skip = (controller.value.position - const Duration(seconds: 15)).inMilliseconds;
    anyVPController.seekTo(Duration(milliseconds: max(skip, beginning)));
  }

  /// Called when player controls visibility should be changed.
  void changePlayerControlsVisible(bool visible) {
    setState(() {
      EventManager.instance.postEvent(AnyVideoPlayerEventType.controlsVisibleChange, params: visible);
      controlsVisible = visible;
    });
  }
}
