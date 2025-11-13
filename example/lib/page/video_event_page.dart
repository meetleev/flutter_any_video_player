import 'package:any_video_player/any_video_player.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class VideoEventPage extends StatefulWidget {
  const VideoEventPage({super.key});

  @override
  State<VideoEventPage> createState() => _VideoEventPageState();
}

class _VideoEventPageState extends State<VideoEventPage> {
  AnyVideoPlayerController? _anyVideoPlayerController;
  String _event = '';

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _anyVideoPlayerController!.addPlayerEventListener(_onPlayerEvent);
  }

  void _onPlayerEvent(AnyVideoPlayerEvent event) {
    final params = event.data;
    switch (event.eventType) {
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
        _event = 'finished';
        break;
      case AnyVideoPlayerEventType.fullScreenChange:
        _event = params as bool ? 'enterScreen' : 'exitScreen';
        break;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _loadVideo() {
    final oldAnyVideoPlayerController = _anyVideoPlayerController;
    oldAnyVideoPlayerController?.dispose();
    _anyVideoPlayerController = AnyVideoPlayerController(
      dataSource: VideoPlayerDataSource.asset(assetVideoUrl),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VideoPlayer Event')),
      body: null != _anyVideoPlayerController
          ? Stack(
              children: [
                AnyVideoPlayer(controller: _anyVideoPlayerController!),
                Container(
                  alignment: Alignment.topCenter,
                  child: Text(_event, style: const TextStyle(fontSize: 20)),
                ),
              ],
            )
          : Container(),
    );
  }

  @override
  void dispose() {
    _anyVideoPlayerController?.dispose();
    super.dispose();
  }
}
