import 'package:any_video_player/any_video_player.dart';
import 'package:example/constants.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:path_provider/path_provider.dart';

class DataSourcePage extends StatefulWidget {
  const DataSourcePage({Key? key}) : super(key: key);

  @override
  State<DataSourcePage> createState() => _DataSourcePageState();
}

class _DataSourcePageState extends State<DataSourcePage> {
  AnyVideoPlayerController? _anyVideoPlayerController;
  final GroupButtonController _groupButtonController =
      GroupButtonController(selectedIndex: 0);

  @override
  void initState() {
    super.initState();
    _loadVideo(VideoPlayerDataSourceType.values[0]);
  }

  _loadVideo(VideoPlayerDataSourceType type) {
    _anyVideoPlayerController?.disposeAll();
    switch (type) {
      case VideoPlayerDataSourceType.asset:
        _anyVideoPlayerController = AnyVideoPlayerController(
            dataSource: VideoPlayerDataSource.asset(assetVideoUrl));
        setState(() {});
        break;
      case VideoPlayerDataSourceType.network:
        _anyVideoPlayerController = AnyVideoPlayerController(
            dataSource: VideoPlayerDataSource.network(remoteVideoUrl),
            controlsConf: ControlsConfiguration(paddingBottom: 10));
        setState(() {});
        break;
      case VideoPlayerDataSourceType.file:
        getTemporaryDirectory().then((directory) {
          final String url = '${directory.path}/$fileVideoName';
          _anyVideoPlayerController = AnyVideoPlayerController(
              dataSource: VideoPlayerDataSource.file(url));
          setState(() {});
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data source'),
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
                        buttons: const ['asset', 'network', 'file'],
                        onSelected: (title, idx, selected) {
                          _groupButtonController.selectIndex(idx);
                          _loadVideo(VideoPlayerDataSourceType.values[idx]);
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
