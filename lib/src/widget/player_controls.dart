import 'package:any_video_player/src/any_video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'cupertino_controls.dart';
import 'material_controls.dart';

class PlayerControls extends StatefulWidget {
  final AnyVideoPlayerController controller;

  const PlayerControls({Key? key, required this.controller}) : super(key: key);

  @override
  State<PlayerControls> createState() => PlayerControlsState();
}

class PlayerControlsState extends State<PlayerControls> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        Theme.of(context).textTheme.bodyLarge!.backgroundColor;
    final AnyVideoPlayerController controller = widget.controller;
    double? aspectRatio;
    if (controller.isFullScreen) {}
    aspectRatio ??= 16 / 9;
    return Center(
      child: Container(
        color: controller.backgroundColor ?? backgroundColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: _buildPlayerControls(context, controller),
        ),
      ),
    );
  }

  Widget _buildPlayerControls(
      BuildContext context, AnyVideoPlayerController anyVideoPlayerController) {
    var controller = anyVideoPlayerController.videoPlayerController;
    return Stack(
      children: [
        if (null != anyVideoPlayerController.placeholder)
          anyVideoPlayerController.placeholder!,
        if (controller.value.isInitialized)
          InteractiveViewer(
            child: Center(
              child: ClipRect(
                child: SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    // fit: BoxFit.fill,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (controller.value.isInitialized)
          !anyVideoPlayerController.isFullScreen
              ? _buildControls(context, anyVideoPlayerController)
              : SafeArea(
                  bottom: false,
                  child: _buildControls(context, anyVideoPlayerController),
                ),
      ],
    );
  }

  _buildControls(
      BuildContext context, AnyVideoPlayerController anyVideoPlayerController) {
    if (anyVideoPlayerController.showControls) {
      return anyVideoPlayerController.customControls ??
          _controlsAdapter(context);
    }
    return const SizedBox();
  }

  _controlsAdapter(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const MaterialControls();
      // case TargetPlatform.macOS:
      // case TargetPlatform.windows:
      // case TargetPlatform.linux:
      //   return const MaterialDesktopControls();
      case TargetPlatform.iOS:
        return const CupertinoControls();
      default:
        return const MaterialControls();
    }
  }
}
