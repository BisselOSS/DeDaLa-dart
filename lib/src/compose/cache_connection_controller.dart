import 'dart:async';

abstract class ComposeEnvironment<T> {
  void add(T event);

  void addCancelable(StreamSubscription<Object?> subscription);
}

typedef OnStart<T> = void Function(ComposeEnvironment<T> environment);

class CacheConnectionController<T> implements ComposeEnvironment<T> {
  late final _streamController = StreamController<T>(
    onListen: _onStart,
    onPause: _onPause,
    onResume: _onResume,
    onCancel: _onCancel,
  );

  OnStart<T> onStart;
  final _subscriptions = <StreamSubscription<Object?>>[];

  /// Public

  Stream<T> get stream => _streamController.stream;

  CacheConnectionController({required this.onStart});

  @override
  void add(T event) => _streamController.add(event);

  @override
  void addCancelable(StreamSubscription<Object?> subscription) =>
      _subscriptions.add(subscription);

  void _onStart() => onStart(this);

  void _onCancel() => _subscriptions.forEach(
        (subscription) => unawaited(subscription.cancel()),
      );

  void _onPause([Future<void>? resumeSignal]) => _subscriptions
      .forEach((subscription) => subscription.pause(resumeSignal));

  void _onResume() =>
      _subscriptions.forEach((subscription) => subscription.resume());
}
