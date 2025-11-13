import 'package:any_video_player/any_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';

class DataSourcePage extends StatefulWidget {
  const DataSourcePage({super.key});

  @override
  State<DataSourcePage> createState() => _DataSourcePageState();
}

class _DataSourcePageState extends State<DataSourcePage> {
  AnyVideoPlayerController? _anyVideoPlayerController;
  final GroupButtonController _groupButtonController = GroupButtonController(
    selectedIndex: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadVideo(VideoPlayerDataSourceType.values[0]);
  }

  void _loadVideo(VideoPlayerDataSourceType type) {
    final oldAnyVideoPlayerController = _anyVideoPlayerController;
    oldAnyVideoPlayerController?.dispose();
    switch (type) {
      case VideoPlayerDataSourceType.asset:
        _anyVideoPlayerController = AnyVideoPlayerController(
          dataSource: VideoPlayerDataSource.asset(assetVideoUrl),
        );
        setState(() {});
        break;
      case VideoPlayerDataSourceType.network:
        _anyVideoPlayerController = AnyVideoPlayerController(
          dataSource: VideoPlayerDataSource.network(remoteVideoUrl),
          controlsConf: ControlsConfiguration(paddingBottom: 10),
        );
        setState(() {});
        break;
      case VideoPlayerDataSourceType.file:
        getTemporaryDirectory().then((directory) {
          final String url = '${directory.path}/$fileVideoName';
          _anyVideoPlayerController = AnyVideoPlayerController(
            dataSource: VideoPlayerDataSource.file(url),
          );
          setState(() {});
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> buttonLabs = ['asset', 'network'];
    if (!kIsWeb) {
      buttonLabs.add('file');
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Data source')),
      body: null != _anyVideoPlayerController
          ? Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AnyVideoPlayer(controller: _anyVideoPlayerController!),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  child: GroupButton(
                    controller: _groupButtonController,
                    buttons: buttonLabs,
                    onSelected: (title, idx, selected) {
                      _groupButtonController.selectIndex(idx);
                      _loadVideo(VideoPlayerDataSourceType.values[idx]);
                    },
                  ),
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
