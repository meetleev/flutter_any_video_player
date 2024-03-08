import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../any_video_player.dart';
import '../video_progress_colors.dart';
import 'center_play_button.dart';
import 'progress_bar_adapter.dart';

abstract class ControlsState<T extends StatefulWidget> extends State<T> {
  AnyVideoPlayerController? _anyVPController;

  AnyVideoPlayerController get anyVPController => _anyVPController!;

  VideoPlayerController get controller => anyVPController.videoPlayerController;

  ControlsConfiguration get controlsConf =>
      anyVPController.controlsConfiguration;

  bool wasLoading = false;
  Timer? _hideControlsTimer;
  bool _dragging = false;
  bool controlsVisible = true;

  bool get isFinished {
    if (controller.value.isInitialized) {
      return controller.value.position >= controller.value.duration;
    }
    return false;
  }

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
      if (!isFinished) {
        if (!controller.value.isPlaying) {
          _hideControlsTimer?.cancel();
          changePlayerControlsVisible(true);
        }
        setState(() {});
      } else {
        _hideControlsTimer?.cancel();
        changePlayerControlsVisible(true);
      }
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
          anyVPController.initialize().then((value) => anyVPController.play());
        } else {
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
    changePlayerControlsVisible(true);
  }

  void _startHideControlsTimer() {
    final hideControlsTimer = anyVPController.hideControlsTimer;
    _hideControlsTimer = Timer(hideControlsTimer, () {
      changePlayerControlsVisible(false);
    });
  }

  Widget buildMain({required Widget child}) {
    return GestureDetector(
      onTap: () => _restartControlsTimer(),
      child: child,
    );
  }

  Widget buildHitArea() {
    final bool showPlayButton = anyVPController.showPlayButton &&
        !controller.value.isPlaying &&
        !_dragging;

    return GestureDetector(
      onTap: () {
        if (!controller.value.isInitialized) return;
        if (controller.value.isPlaying) {
          if (controlsVisible) {
            changePlayerControlsVisible(false);
          } else {
            _restartControlsTimer();
          }
        } else {
          playPause();
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
    final skip = (controller.value.position + const Duration(seconds: 15))
        .inMilliseconds;
    anyVPController.seekTo(Duration(milliseconds: min(skip, end)));
  }

  void skipBack() {
    _restartControlsTimer();
    final beginning = Duration.zero.inMilliseconds;
    final skip = (controller.value.position - const Duration(seconds: 15))
        .inMilliseconds;
    anyVPController.seekTo(Duration(milliseconds: max(skip, beginning)));
  }

  /// Called when player controls visibility should be changed.
  void changePlayerControlsVisible(bool visible) {
    setState(() {
      anyVPController.emit(AnyVideoPlayerEvent(
          eventType: AnyVideoPlayerEventType.controlsVisibleChange,
          data: visible));
      controlsVisible = visible;
    });
  }

  @protected
  Widget buildMoreOptionsRow(Widget leftAction, Widget rightAction) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [leftAction, rightAction]);
  }

  @protected
  Widget buildFrameByFrameOption() {
    return buildMoreOptionsRow(
        const Text('FBF Enabled'),
        Switch(
            value: anyVPController.isFrameByFrameEnabled,
            onChanged: (bool selected) {
              anyVPController.setFrameByFrameEnabled(selected);
              Navigator.of(context).pop();
            }));
  }

  @protected
  Widget buildPlaybackSpeedOption({required VoidCallback onPressed}) {
    return buildMoreOptionsRow(
        const Text('PlaybackSpeed'),
        TextButton(
          onPressed: onPressed,
          child: Text('${anyVPController.playBackSpeed.toStringAsFixed(2)}X'),
        ));
  }

  @protected
  List<Widget> buildSpeedOptions() {
    final List<double> speeds = [
      0.25,
      0.5,
      0.75,
      1.0,
      1.25,
      1.5,
      1.75,
      2,
      4,
      8,
      16
    ];
    List<Widget> children = [];
    for (final speed in speeds) {
      children.add(buildSpeedOptionRow(
          speed: speed, selected: anyVPController.playBackSpeed == speed));
      children.add(const Divider());
    }
    return children;
  }

  @protected
  Widget buildSpeedOptionRow({required double speed, required bool selected}) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent,
        width: double.infinity,
        child: buildMoreOptionsRow(
            Text('${speed}X'),
            Offstage(
              offstage: !selected,
              child: const Icon(Icons.done),
            )),
      ),
      onTap: () {
        anyVPController
            .setPlayBackSpeed(speed)
            .then((value) => Navigator.of(context).pop());
      },
    );
  }
}
