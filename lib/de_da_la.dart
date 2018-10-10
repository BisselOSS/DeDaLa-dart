import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/caches/fixed_cache.dart';
import 'package:dedala_dart/compose/cache_connection.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:dedala_dart/policy/update_policy.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class DeDaLa<K, V> implements Cache<K, V> {
  final Cache<K, V> cache;

  DeDaLa() : cache = null;

  DeDaLa._internal(this.cache);

  DeDaLa<K, V> connect(
      {FixedGet<V> readFrom,
      ReadPolicy<V> readPolicy,
      FixedSet<V> insertTo,
      InsertPolicy<V> insertPolicy,
      String name = ""}) {
    if (readFrom == null) readFrom = () => Observable.just(null);
    if (readPolicy == null) readPolicy = ReadPolicy.Always();

    if (insertTo == null) insertTo = (item) => Observable<V>.just(item);
    if (insertPolicy == null) insertPolicy = InsertPolicy.Always();

    return connectCache(
        source: FixedCache(readFrom: readFrom, insertTo: insertTo, name: name),
        readPolicy: readPolicy,
        insertPolicy: insertPolicy);
  }

  DeDaLa<K, V> connectCache(
      {@required Cache<K, V> source,
      InsertPolicy<V> insertPolicy,
      ReadPolicy<V> readPolicy}) {
    var cache = CacheConnection(this, source, readPolicy, insertPolicy);
    return DeDaLa._internal(cache);
  }

  @override
  Observable<V> get(K key) => cache.get(key);

  @override
  Observable<void> set(K key, V value) => cache.set(key, value);
}
