import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../any_video_player_controller.dart';
import 'cupertino_controls.dart';

class PlayerControls extends StatelessWidget {
  final AnyVideoPlayerController controller;

  const PlayerControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        Theme.of(context).textTheme.bodyLarge!.backgroundColor;
    // if (controller.isFullScreen) {}
    final videoController = controller.videoPlayerController;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        MediaQueryData mediaQueryData = MediaQuery.of(context);
        bool needFix = false;
        BoxConstraints fixConstraints = constraints;
        Size fixSize = videoController.value.size.isEmpty
            ? mediaQueryData.size
            : videoController.value.size;
        if (!constraints.hasBoundedHeight || !constraints.hasBoundedWidth) {
          if (constraints.hasBoundedWidth) {
            double height =
                constraints.maxWidth * fixSize.height / fixSize.width;
            fixConstraints = BoxConstraints.expand(
                width: fixConstraints.maxWidth, height: height);
          } else if (constraints.hasBoundedHeight) {
            double width =
                constraints.maxHeight * fixSize.width / fixSize.height;
            fixConstraints = BoxConstraints.expand(
                width: width, height: fixConstraints.maxHeight);
          } else {
            fixConstraints = BoxConstraints.expand(
                width: fixSize.width, height: fixSize.height);
          }
          needFix = true;
        }
        // debugPrint('fixConstraints:$fixConstraints');
        return Center(
          child: Container(
            color: needFix
                ? Colors.transparent
                : (controller.backgroundColor ?? backgroundColor),
            constraints: fixConstraints,
            child: _buildPlayerControls(
                context,
                Size(fixConstraints.maxWidth, fixConstraints.maxHeight),
                controller),
          ),
        );
      },
    );
  }

  Widget _buildPlayerControls(BuildContext context, Size size,
      AnyVideoPlayerController anyVideoPlayerController) {
    final videoController = anyVideoPlayerController.videoPlayerController;
    if (!videoController.value.isInitialized) {
      return anyVideoPlayerController.placeholder ?? Container();
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        InteractiveViewer(
          child: VideoPlayer(videoController),
        ),
        Positioned.fill(
          child: _buildControls(context, anyVideoPlayerController),
        )
      ],
    );
  }

  Widget _buildControls(BuildContext context,
          AnyVideoPlayerController anyVideoPlayerController) =>
      anyVideoPlayerController.customControls ?? _controlsAdapter(context);

  Widget _controlsAdapter(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      // return const MaterialControls();
      // case TargetPlatform.macOS:
      // case TargetPlatform.windows:
      // case TargetPlatform.linux:
      //   return const MaterialDesktopControls();
      case TargetPlatform.iOS:
        return const CupertinoControls();
      default:
        return const CupertinoControls();
    }
  }
}
