import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CenterPlayButton extends StatelessWidget {
  const CenterPlayButton({
    super.key,
    required this.backgroundColor,
    this.iconColor,
    required this.show,
    required this.isPlaying,
    required this.isFinished,
    this.onPressed,
  });

  final Color backgroundColor;
  final Color? iconColor;
  final bool show;
  final bool isPlaying;
  final bool isFinished;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        constraints: const BoxConstraints.tightFor(width: 72, height: 72),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: AdaptiveButton(
          icon:
              isFinished
                  ? Icon(Icons.replay, color: iconColor, size: 32)
                  : AnimatedPlayPause(
                    color: iconColor,
                    playing: isPlaying,
                    scale: 2,
                  ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// A widget that animates implicitly between a play and a pause icon.
class AnimatedPlayPause extends StatefulWidget {
  const AnimatedPlayPause({
    super.key,
    required this.playing,
    this.scale = 1,
    this.color,
  });

  final double scale;
  final bool playing;
  final Color? color;

  @override
  State<StatefulWidget> createState() => AnimatedPlayPauseState();
}

class AnimatedPlayPauseState extends State<AnimatedPlayPause>
    with SingleTickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    value: widget.playing ? 1 : 0,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didUpdateWidget(AnimatedPlayPause oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing != oldWidget.playing) {
      if (widget.playing) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.scale,
      child: AnimatedIcon(
        color: widget.color,
        icon: AnimatedIcons.play_pause,
        progress: animationController,
      ),
    );
  }
}

class AdaptiveButton extends StatelessWidget {
  /// The size of the icon inside the button.
  ///
  /// If null, uses [IconThemeData.size]. If it is also null, the default size
  /// is 24.0.
  ///
  /// The size given here is passed down to the widget in the [icon] property
  /// via an [IconTheme]. Setting the size here instead of in, for example, the
  /// [Icon.size] property allows the [IconButton] to size the splash area to
  /// fit the [Icon]. If you were to set the size of the [Icon] using
  /// [Icon.size] instead, then the [IconButton] would default to 24.0 and then
  /// the [Icon] itself would likely get clipped.
  final double? iconSize;

  /// If this is set to null, the button will be disabled.
  final VoidCallback? onPressed;

  /// See [Icon], [ImageIcon].
  final Widget icon;

  const AdaptiveButton({
    super.key,
    this.iconSize,
    this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        return IconButton(iconSize: iconSize, onPressed: onPressed, icon: icon);
      case TargetPlatform.iOS:
        return CupertinoButton(
          minimumSize: null != iconSize ? Size.fromRadius(iconSize!) : null,
          onPressed: onPressed,
          child: icon,
        );
      default:
        return IconButton(iconSize: iconSize, onPressed: onPressed, icon: icon);
    }
  }
}
