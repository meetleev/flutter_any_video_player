import 'package:any_video_player/any_video_player.dart';
import 'package:example/constants.dart';
import 'package:flutter/material.dart';

class VideoFrameByFramePage extends StatefulWidget {
  const VideoFrameByFramePage({super.key});

  @override
  State<VideoFrameByFramePage> createState() => _VideoFrameByFramePageState();
}

class _VideoFrameByFramePageState extends State<VideoFrameByFramePage> {
  AnyVideoPlayerController? _anyVideoPlayerController;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() {
    _anyVideoPlayerController = AnyVideoPlayerController(
        frameByFrameEnabled: true,
        dataSource: VideoPlayerDataSource.asset(assetVideoUrl));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoPlayer Event'),
      ),
      body: null != _anyVideoPlayerController
          ? Stack(children: [
              AnyVideoPlayer(controller: _anyVideoPlayerController!),
            ])
          : Container(),
    );
  }

  @override
  void dispose() {
    _anyVideoPlayerController?.dispose();
    super.dispose();
  }
}
