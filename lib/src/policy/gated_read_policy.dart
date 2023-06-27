import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/compose/cache_connection_controller.dart';
import 'package:dedala_dart/src/compose/read_connector.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:dedala_dart/src/util/gate.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class GatedReadPolicy<K, V> implements ReadPolicy<K, V> {
  final Duration duration;

  GatedReadPolicy(this.duration);

  @override
  ReadConnector<K, V> createConnector(Cache<K, V> first, Cache<K, V> second) =>
      _GatedReadConnector(first, second, duration);
}

class _GatedReadConnector<K, V> implements ReadConnector<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;
  final Duration duration;
  final Gate gate;

  _GatedReadConnector(this.first, this.second, this.duration)
      : gate = Gate(duration, initialValue: true);

  final lastValue = PublishSubject<V?>();

  final lastNow = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Stream<V?> get(K key) => CacheConnectionController<V?>(onStart: (env) {
        if (gate.isOpen) {
          gate.close();

          env.addCancelable(first
              .get(key)
              .doOnData(env.add)
              .flatMap((_) => second.get(key))
              .doOnData(env.add)
              .doOnData(lastValue.add)
              .listen((_) {}));
        } else {
          env.addCancelable(first
              .get(key)
              .doOnData(env.add)
              .flatMap((_) => lastValue.take(1))
              .doOnData(env.add)
              .listen((_) {}));
        }
      }).stream;
}
