import 'package:flutter/widgets.dart';
import '../any_video_player.dart';
import 'widget/player_controls.dart';

class AnyVideoPlayer extends StatefulWidget {
  final AnyVideoPlayerController controller;

  const AnyVideoPlayer({super.key, required this.controller});

  @override
  State<AnyVideoPlayer> createState() => AnyVideoPlayerState();
}

class AnyVideoPlayerState extends State<AnyVideoPlayer> {
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
    widget.controller.dispose();
    super.dispose();
  }

  void _onPlayerEvent(AnyVideoPlayerEvent event) {
    if (AnyVideoPlayerEventType.initialized == event.eventType) {
      if (mounted) {
        setState(() {});
      }
    }
  }
}
