import 'package:any_video_player/any_video_player.dart';
import 'package:example/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VideoEventPage extends StatefulWidget {
  const VideoEventPage({super.key});

  @override
  State<VideoEventPage> createState() => _VideoEventPageState();
}

class _VideoEventPageState extends State<VideoEventPage> {
  AnyVideoPlayerController? _anyVideoPlayerController;
  late String _event = '';

  @override
  void initState() {
    super.initState();
    _loadVideo(true);
    _anyVideoPlayerController!.addEventListener(_onPlayerEvent);
  }

  _onPlayerEvent(AnyVideoPlayerEventType eventType, dynamic params) {
    switch (eventType) {
      case AnyVideoPlayerEventType.initialized:
        _event = 'initialized';
        break;
      case AnyVideoPlayerEventType.play:
        _event = 'play';
        break;
      case AnyVideoPlayerEventType.pause:
        _event = 'pause';
        break;
      case AnyVideoPlayerEventType.seekTo:
        _event = 'seekTo $params';
        break;
      case AnyVideoPlayerEventType.controlsVisibleChange:
        _event =
            'controlsVisibleChange ${params as bool ? 'visible' : 'invisible'}';
        break;
      case AnyVideoPlayerEventType.finished:
        if (kDebugMode) {
          print('finished');
        }
        _event = 'finished';
        break;
    }
    setState(() {});
  }

  _loadVideo(bool align) {
    _anyVideoPlayerController?.dispose();
    _anyVideoPlayerController = AnyVideoPlayerController(
        dataSource: VideoPlayerDataSource.asset(assetVideoUrl),
        controlsConf: ControlsConfiguration(autoAlignVideoBottom: align));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('align video bottom'),
      ),
      extendBodyBehindAppBar: true,
      body: null != _anyVideoPlayerController
          ? Stack(
              children: [
                AnyVideoPlayer(controller: _anyVideoPlayerController!),
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(_event),
                )
              ],
            )
          : Container(),
    );
  }

  @override
  void dispose() {
    _anyVideoPlayerController?.removeEventListener(_onPlayerEvent);
    _anyVideoPlayerController?.dispose();
    super.dispose();
  }
}
