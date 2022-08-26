import 'package:any_video_player/src/widget/player_controls.dart';
import 'package:any_video_player/src/video_player_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
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
    _initializeVideo();
    super.initState();
  }

  _initializeVideo(){
    if (!widget.controller.videoPlayerController.value.isInitialized) {
      widget.controller.videoPlayerController.initialize().then((value) => setState(() {
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnyVideoPlayerControllerProvider(
        controller: widget.controller,
        child: ChangeNotifierProvider(
          create: (_) => VideoPlayerNotifier(),
          child: PlayerControls(
            controller: widget.controller,
          ),
        ));
  }

  @override
  void didUpdateWidget(AnyVideoPlayer oldWidget) {
    if (oldWidget.controller != widget.controller) {
      _initializeVideo();
    }
    super.didUpdateWidget(oldWidget);
  }
}
