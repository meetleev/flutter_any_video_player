import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../any_video_player.dart';
import 'widget/player_controls.dart';

class AnyVideoPlayer extends StatefulWidget {
  /// the controller of [AnyVideoPlayer].
  final AnyVideoPlayerController controller;

  /// Whether to automatically destroy the controller
  final bool isAutoDisposeController;

  const AnyVideoPlayer(
      {super.key,
      required this.controller,
      this.isAutoDisposeController = true});

  @override
  State<AnyVideoPlayer> createState() => _AnyVideoPlayerState();
}

class _AnyVideoPlayerState extends State<AnyVideoPlayer> {
  get controlsConfiguration => widget.controller.controlsConfiguration;

  AnimatedWidget _defaultRoutePageBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      AnyVideoPlayerControllerProvider controllerProvider) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: controllerProvider,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    widget.controller.addPlayerEventListener(_onPlayerEvent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnyVideoPlayerControllerProvider(
        controller: widget.controller,
        child: PlayerControls(
          controller: widget.controller,
        ));
  }

  @override
  void dispose() {
    if (widget.isAutoDisposeController) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AnyVideoPlayer oldWidget) {
    if (oldWidget.controller != widget.controller) {
      widget.controller.addPlayerEventListener(_onPlayerEvent);
      if (oldWidget.isAutoDisposeController) {
        oldWidget.controller.dispose();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onPlayerEvent(AnyVideoPlayerEvent event) {
    if (AnyVideoPlayerEventType.initialized == event.eventType) {
      if (mounted) {
        setState(() {});
      }
    } else if (AnyVideoPlayerEventType.fullScreenChange == event.eventType) {
      if (mounted) {
        _onFullScreenChanged(event.data as bool);
      }
    }
  }

  void _onFullScreenChanged(bool isFullScreen) {
    if (isFullScreen) {
      _enterFullScreen();
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      widget.controller.onExitFullScreen();
    }
  }

  Future<void> _enterFullScreen() async {
    final TransitionRoute route = PageRouteBuilder(pageBuilder: (BuildContext c,
        Animation<double> animation, Animation<double> secondaryAnimation) {
      widget.controller.onEnterFullScreen();
      final controllerProvider = AnyVideoPlayerControllerProvider(
          controller: widget.controller,
          child: PlayerControls(
            controller: widget.controller,
          ));
      final routePageBuilder = _defaultRoutePageBuilder;
      return routePageBuilder(
          c, animation, secondaryAnimation, controllerProvider);
    });
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final aspectRatio =
        widget.controller.videoPlayerController.value.aspectRatio;
    if (1 > aspectRatio) {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    } else {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
    if (!mounted) return;
    await Navigator.of(context, rootNavigator: true).push(route);
  }
}
