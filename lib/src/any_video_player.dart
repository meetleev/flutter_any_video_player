import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'any_video_player_controller.dart';
import 'configuration/controls_configuration.dart';
import 'events/any_video_player_event.dart';
import 'events/any_video_player_event_type.dart';
import 'widget/player_controls.dart';

class AnyVideoPlayer extends StatefulWidget {
  /// the controller of [AnyVideoPlayer].
  final AnyVideoPlayerController controller;

  const AnyVideoPlayer({super.key, required this.controller});

  @override
  State<AnyVideoPlayer> createState() => _AnyVideoPlayerState();
}

class _AnyVideoPlayerState extends State<AnyVideoPlayer> {
  ControlsConfiguration get controlsConfiguration =>
      widget.controller.controlsConfiguration;
  Orientation? _orgOrientation;

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
    if (null == _orgOrientation) {
      final mediaData = MediaQuery.of(context);
      _orgOrientation = mediaData.orientation;
    }
    return AnyVideoPlayerControllerProvider(
        controller: widget.controller,
        child: PlayerControls(
          controller: widget.controller,
        ));
  }

  @override
  void didUpdateWidget(AnyVideoPlayer oldWidget) {
    if (oldWidget.controller != widget.controller) {
      widget.controller.addPlayerEventListener(_onPlayerEvent);
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
      final mediaData = MediaQuery.of(context);
      if (_orgOrientation != mediaData.orientation) {
        if (Orientation.portrait == _orgOrientation) {
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ]);
        }
      }
      widget.controller.onExitFullScreen();
      Navigator.of(context, rootNavigator: true).pop();
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
