import 'package:any_video_player/any_video_player.dart';
import 'package:example/constants.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:path_provider/path_provider.dart';

class BarAlignVideoBottomPage extends StatefulWidget {
  const BarAlignVideoBottomPage({Key? key}) : super(key: key);

  @override
  State<BarAlignVideoBottomPage> createState() =>
      _BarAlignVideoBottomPageState();
}

class _BarAlignVideoBottomPageState extends State<BarAlignVideoBottomPage> {
  AnyVideoPlayerController? _anyVideoPlayerController;
  final GroupButtonController _groupButtonController =
      GroupButtonController(selectedIndex: 0);

  @override
  void initState() {
    super.initState();
    _loadVideo(true);
  }

  _loadVideo(bool align) {
    _anyVideoPlayerController?.disposeAll();
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
                  padding: const EdgeInsets.only(top: 100),
                  child: Row(
                    children: [
                      GroupButton(
                        controller: _groupButtonController,
                        buttons: const ['aligned', 'unaligned'],
                        onSelected: (title, idx, selected) {
                          _groupButtonController.selectIndex(idx);
                          _loadVideo(0 == idx);
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
