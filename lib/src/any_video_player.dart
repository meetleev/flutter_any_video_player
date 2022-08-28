import 'package:any_video_player/src/event/any_video_player_event_type.dart';
import 'package:any_video_player/src/widget/player_controls.dart';
import 'package:flutter/widgets.dart';
import 'any_video_player_controller.dart';

class AnyVideoPlayer extends StatefulWidget {
  final AnyVideoPlayerController controller;

  const AnyVideoPlayer({super.key, required this.controller});

  @override
  State<AnyVideoPlayer> createState() => AnyVideoPlayerState();
}

class AnyVideoPlayerState extends State<AnyVideoPlayer> {
  @override
  void initState() {
    widget.controller.addEventListener(_onPlayerEvent);
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
    widget.controller.removeEventListener(_onPlayerEvent);
    super.dispose();
  }

  void _onPlayerEvent(eventType, params) {
    if (AnyVideoPlayerEventType.initialized == eventType) {
      setState(() {});
    }
  }
}
