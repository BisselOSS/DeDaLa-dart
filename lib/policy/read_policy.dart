import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/compose/read_connector.dart';
import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/gated_read_policy.dart';
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
      GatedReadPolicy(duration);

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
