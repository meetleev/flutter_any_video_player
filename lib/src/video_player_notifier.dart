import 'package:flutter/widgets.dart';

class VideoPlayerNotifier extends ChangeNotifier {
  bool _hideControls = false;

  bool get hideControls => _hideControls;

  set hideControls(bool value) {
    _hideControls = value;
    notifyListeners();
  }
}
