import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/compose/insert_connector.dart';
import 'package:dedala_dart/optional.dart';

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

  static InsertPolicy<K, V> IfEmpty<K, V>() =>
      ConditionalInsertPolicy((optional) => optional.isNotPresent);
}

class ConditionalInsertPolicy<K, V> implements InsertPolicy<K, V> {
  final InsertCondition<V> insertCondition;

  ConditionalInsertPolicy(this.insertCondition);

  @override
  InsertConnector<K, V> createConnector(
          Cache<K, V> first, Cache<K, V> second) =>
      ConditionalInsertConnector(first, second, insertCondition);
}
