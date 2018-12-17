import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/compose/read_connector.dart';
import 'package:dedala_dart/src/optional.dart';
import 'package:dedala_dart/src/policy/gated_read_policy.dart';
import 'package:meta/meta.dart';

/**
 * Decides if the cache should be read.
 */
typedef bool ReadCondition<T>(Optional<T> item);

abstract class ReadPolicy<K, V> {
  ReadConnector<K, V> createConnector(Cache<K, V> first, Cache<K, V> second);

  static ReadPolicy<K, V> Always<K, V>({bool discardPrevious = false}) =>
      ConditionalReadPolicy(
        (optional) => true,
        discardPrevious,
      );

  static ReadPolicy<K, V> Gated<K, V>({@required Duration duration}) =>
      GatedReadPolicy(duration);

  static ReadPolicy<K, V> IfDownstreamEmpty<K, V>(
          {bool discardPrevious = true}) =>
      ConditionalReadPolicy(
        (optional) => optional.isNotPresent,
        discardPrevious,
      );

  static ReadPolicy<K, List<V>> IfDownstreamListEmpty<K, V>(
          {bool discardPrevious = true}) =>
      ConditionalReadPolicy(
        (optional) => optional.value?.isEmpty,
        discardPrevious,
      );

  static ReadPolicy<K, V> Never<K, V>({bool discardPrevious = true}) =>
      ConditionalReadPolicy(
        (optional) => false,
        discardPrevious,
      );
}

class ConditionalReadPolicy<K, V> implements ReadPolicy<K, V> {
  final ReadCondition<V> readCondition;
  final bool discardPrevious;

  ConditionalReadPolicy(this.readCondition, this.discardPrevious);

  @override
  ReadConnector<K, V> createConnector(Cache<K, V> first, Cache<K, V> second) =>
      ConditionalReadConnector(
        first,
        second,
        readCondition,
        discardPrevious,
      );
}
