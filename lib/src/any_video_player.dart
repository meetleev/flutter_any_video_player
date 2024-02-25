import 'package:flutter/widgets.dart';
import '../any_video_player.dart';
import 'widget/player_controls.dart';

class AnyVideoPlayer extends StatefulWidget {
  /// the controller of [AnyVideoPlayer].
  final AnyVideoPlayerController controller;

  /// Whether to automatically destroy the controller
  final bool isAutoDisposeController;

  const AnyVideoPlayer(
      {super.key,
      required this.controller,
      this.isAutoDisposeController = true});

  @override
  State<AnyVideoPlayer> createState() => _AnyVideoPlayerState();
}

class _AnyVideoPlayerState extends State<AnyVideoPlayer> {
  @override
  void initState() {
    widget.controller.addPlayerEventListener(_onPlayerEvent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnyVideoPlayerControllerProvider(
        controller: widget.controller,
        child: PlayerControls(
          controller: widget.controller,
        ));
  }

  @override
  void dispose() {
    if (widget.isAutoDisposeController) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AnyVideoPlayer oldWidget) {
    if (oldWidget.controller != widget.controller) {
      widget.controller.addPlayerEventListener(_onPlayerEvent);
      if (oldWidget.isAutoDisposeController) {
        oldWidget.controller.dispose();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onPlayerEvent(AnyVideoPlayerEvent event) {
    if (AnyVideoPlayerEventType.initialized == event.eventType) {
      if (mounted) {
        setState(() {});
      }
    }
  }
}
