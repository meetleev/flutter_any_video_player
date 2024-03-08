import 'package:any_video_player/src/video_progress_colors.dart';
import 'package:flutter/material.dart';

class ControlsConfiguration {
  static const Color defaultCupertinoBackgroundColor =
      Color.fromRGBO(41, 41, 41, 0.7);
  static const Color defaultCupertinoIconColor =
      Color.fromARGB(255, 200, 200, 200);

  /// The colors to use for the Material Progress Bar. By default, the Material
  /// player uses the colors from your Theme.
  final AnyVideoProgressColors? materialProgressColors;

  /// The colors to use for controls on iOS. By default, the iOS player uses
  /// colors sampled from the original iOS 11 designs.
  final AnyVideoProgressColors? cupertinoProgressColors;
  final double paddingBottom;

  /// The colors to use for background on iOS.
  final Color cupertinoBackgroundColor;

  /// The colors to use for background on Material.
  final Color materialBackgroundColor;

  /// The colors to use for icon on Material.
  final Color materialIconColor;

  /// The colors to use for icon on Cupertino.
  final Color cupertinoIconColor;

  ControlsConfiguration(
      {this.materialProgressColors,
      this.cupertinoProgressColors,
      this.paddingBottom = 10,
      this.materialBackgroundColor = Colors.black12,
      this.materialIconColor = Colors.white,
      this.cupertinoBackgroundColor = defaultCupertinoBackgroundColor,
      this.cupertinoIconColor = defaultCupertinoIconColor});
}
