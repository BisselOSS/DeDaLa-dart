import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/compose/insert_connector.dart';
import 'package:dedala_dart/src/optional.dart';

/**
 * Decides if the cache should be updated
 */
typedef bool InsertCondition<T>(Optional<T> item);

abstract class InsertPolicy<K, V> {
  InsertConnector<K, V> createConnector(Cache<K, V> first, Cache<K, V> second);

  static InsertPolicy<K, V> Always<K, V>() =>
      ConditionalInsertPolicy((optional) => true);

  static InsertPolicy<K, V> Never<K, V>() =>
      ConditionalInsertPolicy((optional) => false);

  static InsertPolicy<K, V> IfUpstreamEmpty<K, V>() =>
      ConditionalInsertPolicy((optional) => optional.isNotPresent);

  static InsertPolicy<K, List<V>> IfUpstreamListEmpty<K, V>() =>
      ConditionalInsertPolicy((optional) => optional.value?.isEmpty);
}

class ConditionalInsertPolicy<K, V> implements InsertPolicy<K, V> {
  final InsertCondition<V> insertCondition;

  ConditionalInsertPolicy(this.insertCondition);

  @override
  InsertConnector<K, V> createConnector(
          Cache<K, V> first, Cache<K, V> second) =>
      ConditionalInsertConnector(first, second, insertCondition);
}
