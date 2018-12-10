import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/compose/cache_connection_controller.dart';
import 'package:dedala_dart/compose/read_connector.dart';
import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:dedala_dart/util/functions.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/src/observables/observable.dart';

@immutable
class GatedReadPolicy<K, V> implements ReadPolicy<K, V> {
  final _Gate gate;

  GatedReadPolicy(Duration duration) : gate = _Gate(duration);

  @override
  ReadConnector<K, V> createConnector(Cache<K, V> first, Cache<K, V> second) =>
      _GatedReadConnector(first, second, gate);
}

class _GatedReadConnector<K, V> implements ReadConnector<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;

  final _Gate gate;

  _GatedReadConnector(this.first, this.second, this.gate);

  @override
  Observable<V> get(K key) =>
      CacheConnectionController<Optional<V>>(onStart: (env) {
        Optional<V> lastValue;

        env.addSubscription(first.get(key).map(box).listen((value) {
          // return the last value and don't ask the second cache
          if (gate.isClosed) {
            if (lastValue == null) {
              throw Exception(
                  "Gate can not be glosed if previous stream never emitted a value");
            }

            env.add(lastValue);
          } else {
            env.addSubscription(second.get(key).map(box).listen((value2) {
              lastValue = value2;
              gate.open();
              env.add(value2);
            }));
          }
        }));

        return env;
      }).stream.map(unbox);
}

class _Gate {
  final Duration duration;

  _Gate(this.duration);

  int lastOpen = 0;

  bool get isOpen {
    var now = DateTime.now().millisecond;
    return now - lastOpen > duration.inMilliseconds;
  }

  bool get isClosed => !isOpen;

  void open() {
    lastOpen = DateTime.now().millisecond;
  }
}
