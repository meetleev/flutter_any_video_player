import 'package:any_video_player/any_video_player.dart';
import 'package:flutter/material.dart';

class MaterialHomePage extends StatefulWidget {
  const MaterialHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MaterialHomePage> createState() => _MaterialHomePageState();
}

class _MaterialHomePageState extends State<MaterialHomePage> {
  AnyVideoPlayerController? _anyVideoPlayerController;

  @override
  void initState() {
    super.initState();
    _loadVideo(VideoPlayerDataSourceType.asset);
  }

  _loadVideo(VideoPlayerDataSourceType type) {
    _anyVideoPlayerController?.dispose();
    switch (type) {
      case VideoPlayerDataSourceType.asset:
        _anyVideoPlayerController =
            AnyVideoPlayerController(dataSource: VideoPlayerDataSource.asset('assets/Butterfly-209.mp4'));
        break;
      case VideoPlayerDataSourceType.network:
        _anyVideoPlayerController = AnyVideoPlayerController(
            dataSource: VideoPlayerDataSource.network(
                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
            barConfiguration: BottomBarConfiguration(paddingBottom: 10));
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).textTheme.button!.color;
    return Scaffold(
      appBar: AppBar(
        title: const Text('video test'),
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
                      ElevatedButton(
                        onPressed: () {
                          _loadVideo(VideoPlayerDataSourceType.network);
                        },
                        child: Text(
                          'network',
                          style: TextStyle(color: iconColor),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _loadVideo(VideoPlayerDataSourceType.asset);
                        },
                        child: Text(
                          'asset',
                          style: TextStyle(color: iconColor),
                        ),
                      )
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
    _anyVideoPlayerController?.dispose();
    super.dispose();
  }
}
