import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/caches/lambda_cache.dart';
import 'package:dedala_dart/src/compose/cache_connection.dart';
import 'package:dedala_dart/src/compose/nudge_cache.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class DeDaLa<K, V> implements Cache<K, V> {
  final Cache<K, V> _cache;

  DeDaLa() : _cache = null;

  DeDaLa._internal(this._cache);

  DeDaLa<K, V> connect(
      {Get<K, V> readFrom,
      ReadPolicy<K, V> readPolicy,
      Set<K, V> insertTo,
      InsertPolicy<K, V> insertPolicy}) {
    if (readFrom == null) readFrom = (key) => Observable.just(null);
    if (readPolicy == null) readPolicy = ReadPolicy.Never();

    if (insertTo == null) insertTo = (key, item) => Observable<V>.just(item);
    if (insertPolicy == null) insertPolicy = InsertPolicy.Always();

    return connectCache(
        source: LambdaCache(readFrom: readFrom, insertTo: insertTo),
        readPolicy: readPolicy,
        insertPolicy: insertPolicy);
  }

  DeDaLa<K, V> connectCache(
      {@required Cache<K, V> source,
      InsertPolicy<K, V> insertPolicy,
      ReadPolicy<K, V> readPolicy}) {
    //TODO
    // find better way of handling this
    // since this will ignore all insert and read polices for the first cache
    if (_cache == null) {
      return DeDaLa._internal(source);
    }

    return DeDaLa._internal(
      CacheConnection.fromPolicy(
          first: _cache,
          second: source,
          readPolicy: readPolicy,
          insertPolicy: insertPolicy),
    );
  }

  @override
  Observable<V> get(K key) => NudgeCache(_cache).get(key);

  @override
  Observable<V> set(K key, V value) => _cache.set(key, value);
}
