import 'package:flutter/material.dart';
import '../utils.dart';
import '../video_progress_colors.dart';
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
    final widthScale = calculateVideo2ScreenWidthRatio(context, videoSize,
        mediaData: mediaData);
    final barHeight = 48.0 * 1.5 * (0 < widthScale ? widthScale : 1);
    final iconColor = Theme.of(context).textTheme.labelLarge!.color;

    final controls = Stack(
      children: [
        if (wasLoading) _buildLoading(),
        Positioned(
          left: 0,
          right: 0,
          bottom: controlsConf.paddingBottom + barHeight,
          top: 0,
          child: buildHitArea(),
        ),
        Positioned(
          bottom: controlsConf.paddingBottom,
          left: 0,
          right: 0,
          child: SizedBox(
            height: barHeight,
            child: _buildBottomBar(iconColor, barHeight),
          ),
        ),
      ],
    );
    return buildMain(
        child: AbsorbPointer(
            absorbing: !controlsVisible,
            child: anyVPController.isFullScreen
                ? SafeArea(child: controls)
                : controls));
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBottomBar(Color? iconColor, double barHeight) {
    return AnimatedOpacity(
      opacity: !controlsVisible ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: controlsConf.materialBackgroundColor,
        height: barHeight,
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                flex: 2,
                child: Row(
                  children: [
                    if (anyVPController.isLive)
                      Flexible(
                          child: Text(
                        'LIVE',
                        style: TextStyle(color: controlsConf.materialIconColor),
                      ))
                    else
                      _buildPosition(iconColor),
                  ],
                )),
            if (!anyVPController.isLive) _buildProgressBar()
          ],
        ),
      ),
    );
  }

  Widget _buildPosition(Color? iconColor) {
    final position = controller.value.position;
    final duration = controller.value.duration;
    return RichText(
        textAlign: TextAlign.center,
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
    return Flexible(
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
