import 'any_video_player_event_type.dart';

typedef AnyVideoPlayerEventListener = void Function(AnyVideoPlayerEvent event);

class AnyVideoPlayerEvent {
  /// The type of the event. see [AnyVideoPlayerEventType]
  final AnyVideoPlayerEventType eventType;

  /// The data of the event.
  final Object? data;

  AnyVideoPlayerEvent({required this.eventType, this.data});
}
