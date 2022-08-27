import 'package:any_video_player/any_video_player.dart';
import 'package:example/constants.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:path_provider/path_provider.dart';

class VideoBarPaddingBottomPage extends StatefulWidget {
  const VideoBarPaddingBottomPage({Key? key}) : super(key: key);

  @override
  State<VideoBarPaddingBottomPage> createState() =>
      _VideoBarPaddingBottomPageState();
}

class _VideoBarPaddingBottomPageState extends State<VideoBarPaddingBottomPage> {
  AnyVideoPlayerController? _anyVideoPlayerController;
  final GroupButtonController _groupButtonController =
      GroupButtonController(selectedIndex: 0);

  @override
  void initState() {
    super.initState();
    _loadVideo(20);
  }

  _loadVideo(double paddingBottom) {
    _anyVideoPlayerController?.disposeAll();
    _anyVideoPlayerController = AnyVideoPlayerController(
        dataSource: VideoPlayerDataSource.asset(assetVideoUrl),
        controlsConf: ControlsConfiguration(
            paddingBottom: paddingBottom, autoAlignVideoBottom: false));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('video bar padding bottom'),
      ),
      extendBodyBehindAppBar: true,
      body: null != _anyVideoPlayerController
          ? Stack(
              children: [
                AnyVideoPlayer(controller: _anyVideoPlayerController!),
                Container(
                  padding: const EdgeInsets.only(top: 100),
                  child: Row(
                    children: [
                      GroupButton(
                        controller: _groupButtonController,
                        buttons: const [20, 40, 60, 80, 100],
                        onSelected: (int title, idx, selected) {
                          _groupButtonController.selectIndex(idx);
                          _loadVideo(title.toDouble());
                        },
                      ),
                    ],
                  ),
                )
              ],
            )
          : Container(),
    );
  }

  @override
  void dispose() {
    _anyVideoPlayerController?.disposeAll();
    super.dispose();
  }
}
