import 'any_video_player_event_type.dart';

typedef AnyVideoPlayerEventListener = void Function(
    AnyVideoPlayerEventType eventType, dynamic params);

class EventManager {
  static final EventManager _instance = EventManager._();

  static EventManager get instance => _instance;

  factory EventManager() => instance;

  EventManager._();

  final List<AnyVideoPlayerEventListener> _eventListeners = [];

  void addEventListener(AnyVideoPlayerEventListener listener) {
    if (!_eventListeners.contains(listener)) _eventListeners.add(listener);
  }

  void removeEventListener(AnyVideoPlayerEventListener listener) {
    _eventListeners.remove(listener);
  }

  void postEvent(AnyVideoPlayerEventType eventType, {dynamic params}) {
    for (var listener in _eventListeners) {
      listener(eventType, params);
    }
  }

  void removeAll() {
    _eventListeners.clear();
  }
}
