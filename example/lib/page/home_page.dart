import 'dart:io';

import 'package:example/constants.dart';
import 'package:example/page/data_source_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'video_bar_padding_bottom_page.dart';
import 'bar_align_video_bottom_page.dart';

class MaterialHomePage extends StatefulWidget {
  const MaterialHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MaterialHomePage> createState() => _MaterialHomePageState();
}

class _MaterialHomePageState extends State<MaterialHomePage> {
  @override
  void initState() {
    super.initState();
    _saveAssetVideoToFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('video test'),
      ),
      body: ListView(
        children: [..._buildExampleWidgets()],
      ),
    );
  }

  List<Widget> _buildExampleWidgets() {
    return [
      _buildExampleElementWidget('Data source', () {
        _navigateToPage(const DataSourcePage());
      }),
      _buildExampleElementWidget('bottom bar align video bottom', () {
        _navigateToPage(const BarAlignVideoBottomPage());
      }),
      _buildExampleElementWidget('video bottom bar padding bottom', () {
        _navigateToPage(const VideoBarPaddingBottomPage());
      }),
    ];
  }

  Future _navigateToPage(Widget routeWidget) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => routeWidget),
    );
  }

  _buildExampleElementWidget(String name, Function() onClicked) {
    return InkWell(
      onTap: onClicked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.orange,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              name,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  ///Save video to file, so we can use it later
  Future _saveAssetVideoToFile() async {
    var content = await rootBundle.load(assetVideoUrl);
    final directory = await getTemporaryDirectory();
    File file = File('${directory.path}/$fileVideoName');
    await file.writeAsBytes(content.buffer.asUint8List());
  }
}
