import 'package:flutter/material.dart';
import 'package:any_video_player/src/video_progress_colors.dart';
import '../utils.dart';
import 'controls_state.dart';

class MaterialControls extends StatefulWidget {
  const MaterialControls({super.key});

  @override
  State<MaterialControls> createState() => MaterialControlsState();
}

class MaterialControlsState extends ControlsState<MaterialControls> {
  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final videoSize = controller.value.size;
    final offset = controlsConf.autoAlignVideoBottom
        ? calculateVideo2ScreenHeightOffset(context, videoSize,
            mediaData: mediaData)
        : 0;
    final widthScale = calculateVideo2ScreenWidthRatio(context, videoSize,
        mediaData: mediaData);
    final barHeight = 48.0 * 1.5 * (0 < widthScale ? widthScale : 1);
    var bottom = controlsConf.paddingBottom + offset / 2;
    final iconColor = Theme.of(context).textTheme.labelLarge!.color;
    return buildMain(
      child: AbsorbPointer(
        absorbing: !controlsVisible,
        child: Stack(
          children: [
            wasLoading
                ? Center(
                    child: _buildLoading(),
                  )
                : buildHitArea(),
            Container(
              padding: EdgeInsets.only(bottom: bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBottomBar(iconColor, barHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBottomBar(Color? iconColor, double barHeight) {
    return SafeArea(
        bottom: anyVPController.isFullScreen,
        child: AnimatedOpacity(
          opacity: !controlsVisible ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: controlsConf.materialBackgroundColor,
            height: barHeight,
            padding: const EdgeInsets.only(
              left: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (anyVPController.isLive)
                          Expanded(
                              child: Text(
                            'LIVE',
                            style: TextStyle(
                                color: controlsConf.materialIconColor),
                          ))
                        else
                          _buildPosition(iconColor),
                      ],
                    )),
                if (!anyVPController.isLive)
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      children: [_buildProgressBar()],
                    ),
                  ))
              ],
            ),
          ),
        ));
  }

  Widget _buildPosition(Color? iconColor) {
    final position = controller.value.position;
    final duration = controller.value.duration;
    return RichText(
        text: TextSpan(
      text: '${formatDuration(position)} ',
      children: [
        TextSpan(
          text: '/ ${formatDuration(duration)}',
          style: TextStyle(
            fontSize: 14.0,
            color: controlsConf.materialIconColor,
            fontWeight: FontWeight.normal,
          ),
        )
      ],
      style: TextStyle(
        fontSize: 14.0,
        color: controlsConf.materialIconColor,
        fontWeight: FontWeight.bold,
      ),
    ));
  }

  Widget _buildProgressBar() {
    return Expanded(
        child: buildVideoProgressBarAdapter(
      color: controlsConf.materialProgressColors ??
          AnyVideoProgressColors(
            playedColor: Theme.of(context).colorScheme.secondary,
            handleColor: Theme.of(context).colorScheme.secondary,
            bufferedColor:
                Theme.of(context).colorScheme.background.withOpacity(0.5),
            backgroundColor: Theme.of(context).disabledColor.withOpacity(.5),
          ),
    ));
  }
}
