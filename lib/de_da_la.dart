import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/caches/lambda_cache.dart';
import 'package:dedala_dart/compose/cache_connection.dart';
import 'package:dedala_dart/policy/insert/insert_policy.dart';
import 'package:dedala_dart/policy/read/read_policy.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class DeDaLa<K, V> implements Cache<K, V> {
  final Cache<K, V> _cache;

  DeDaLa() : _cache = null;

  DeDaLa._internal(this._cache);

  DeDaLa<K, V> connect(
      {Get<K, V> readFrom,
      ReadPolicy<V> readPolicy,
      Set<K, V> insertTo,
      InsertPolicy<V> insertPolicy}) {
    if (readFrom == null) readFrom = (key) => Observable.just(null);
    if (readPolicy == null) readPolicy = ReadPolicy.Always();

    if (insertTo == null) insertTo = (key, item) => Observable<V>.just(item);
    if (insertPolicy == null) insertPolicy = InsertPolicy.Always();

    return connectCache(
        source: LambdaCache(readFrom: readFrom, insertTo: insertTo),
        readPolicy: readPolicy,
        insertPolicy: insertPolicy);
  }

  DeDaLa<K, V> connectCache(
      {@required Cache<K, V> source,
      InsertPolicy<V> insertPolicy,
      ReadPolicy<V> readPolicy}) {
    //TODO
    // find better way of handling this
    // since this will ignore all insert and read polices for the first cache
    if (_cache == null) {
      return DeDaLa._internal(source);
    }

    var cache = CacheConnection(this, source, readPolicy, insertPolicy);
    return DeDaLa._internal(cache);
  }

  @override
  Observable<V> get(K key) => _cache.get(key);

  @override
  Observable<void> set(K key, V value) => _cache.set(key, value);
}
