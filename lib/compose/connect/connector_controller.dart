import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

abstract class ComposeEnvironment<T> {
  void add(T event);

  void addSubscription(StreamSubscription<T> subscription);
}

typedef ComposeEnvironment<T> OnStart<T>(
    final ComposeEnvironment<T> environment);

class CacheConnectionController<T> implements ComposeEnvironment<T> {
  /**
   * Private
   */
  StreamController<T> _streamController;
  OnStart<T> onStart;
  List<StreamSubscription<T>> _subscriptions = List();

  /**
   * Public
   */

  Observable<T> get stream => Observable(_streamController.stream);

  CacheConnectionController({@required this.onStart}) {
    _streamController = StreamController<T>(
      onListen: _onStart,
      onPause: _onPause,
      onResume: _onResume,
      onCancel: _onCancel,
    );
  }

  /**
   * ComposeEnvironment
   */

  @override
  void add(T event) {
    print("emitted event: $event");
    _streamController.add(event);
  }

  @override
  void addSubscription(StreamSubscription<T> subscription) {
    _subscriptions.add(subscription);
  }

  /**
   * StreamController events
   */

  void _onStart() {
    onStart(this);
  }

  void _onCancel() =>
      _subscriptions.forEach((subscription) => subscription.cancel());

  void _onPause([Future resumeSignal]) => _subscriptions
      .forEach((subscription) => subscription.pause(resumeSignal));

  void _onResume() =>
      _subscriptions.forEach((subscription) => subscription.resume());
}
