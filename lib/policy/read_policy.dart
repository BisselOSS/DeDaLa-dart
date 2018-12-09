import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/compose/read_connector.dart';
import 'package:dedala_dart/optional.dart';
import 'package:meta/meta.dart';

/**
 * Decides if the cache should be read.
 */
typedef bool ReadCondition<T>(Optional<T> item);

abstract class ReadPolicy<K, V> {
  ReadConnector<K, V> createConnector(Cache<K, V> first, Cache<K, V> second);

  static ReadPolicy<K, V> Always<K, V>() =>
      ConditionalReadPolicy((optional) => true);

  static ReadPolicy<K, V> Gated<K, V>({@required Duration duration}) =>
      _GatedReadPolicy(duration);

  static ReadPolicy<K, V> IfEmpty<K, V>() =>
      ConditionalReadPolicy((optional) => optional.isNotPresent);

  static ReadPolicy<K, V> Never<K, V>() =>
      ConditionalReadPolicy((optional) => false);
}

class ConditionalReadPolicy<K, V> implements ReadPolicy<K, V> {
  final ReadCondition<V> readCondition;

  ConditionalReadPolicy(this.readCondition);

  @override
  ReadConnector<K, V> createConnector(Cache<K, V> first, Cache<K, V> second) =>
      ConditionalReadConnector(first, second, readCondition);
}

@immutable
class _GatedReadPolicy<K, V> implements ReadPolicy<K, V> {
  final _Gate gate;

  _GatedReadPolicy(Duration duration) : gate = _Gate(duration);

  @override
  ReadConnector<K, V> createConnector(Cache<K, V> first, Cache<K, V> second) =>
      ConditionalReadConnector(first, second, (Optional<V> item) {
        if (!gate.isOpen) return false;

        gate.open();
        return true;
      });
}

class _Gate {
  final Duration duration;

  _Gate(this.duration);

  int lastOpen = 0;

  bool get isOpen {
    var now = DateTime.now().millisecond;
    return now - lastOpen > duration.inMilliseconds;
  }

  void open() {
    lastOpen = DateTime.now().millisecond;
  }
}
