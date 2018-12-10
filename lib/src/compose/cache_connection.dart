import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/compose/insert_connector.dart';
import 'package:dedala_dart/src/compose/read_connector.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class CacheConnection<K, V> implements Cache<K, V> {
  final ReadConnector<K, V> readConnector;
  final InsertConnector<K, V> insertConnector;

  CacheConnection.fromPolicy(
      {@required Cache<K, V> first,
      @required Cache<K, V> second,
      @required ReadPolicy<K, V> readPolicy,
      @required InsertPolicy<K, V> insertPolicy})
      : readConnector = readPolicy.createConnector(first, second),
        insertConnector = insertPolicy.createConnector(first, second);

  @override
  Observable<V> get(K key) => readConnector.get(key);

  @override
  Observable<V> set(K key, V value) => insertConnector.set(key, value);
}
