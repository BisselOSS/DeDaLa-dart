import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/caches/lambda_cache.dart';
import 'package:dedala_dart/src/compose/cache_connection.dart';
import 'package:dedala_dart/src/compose/nudge_cache.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';

class DeDaLa<K, V> implements Cache<K, V> {
  final Cache<K, V>? _cache;

  DeDaLa() : _cache = null;

  DeDaLa._internal(this._cache);

  DeDaLa<K, V> connect({
    Get<K, V>? readFrom,
    ReadPolicy<K, V>? readPolicy,
    Set<K, V>? insertTo,
    InsertPolicy<K, V>? insertPolicy,
  }) {
    readPolicy ??= readFrom == null ? ReadPolicy.Never() : ReadPolicy.Always();

    insertTo ??= (key, item) => Stream.value(item);

    insertPolicy ??= InsertPolicy.Always();

    return connectCache(
      source: LambdaCache(
        readFrom: (key) {
          assert(
            readFrom != null,
            "$readPolicy allowed a read but not readFrom was specified",
          );
          return readFrom!(key);
        },
        insertTo: insertTo,
      ),
      readPolicy: readPolicy,
      insertPolicy: insertPolicy,
    );
  }

  DeDaLa<K, V> connectCache({
    required Cache<K, V> source,
    InsertPolicy<K, V>? insertPolicy,
    ReadPolicy<K, V>? readPolicy,
  }) {
    //TODO
    // find better way of handling this
    // since this will ignore all insert and read polices for the first cache
    if (_cache == null) {
      return DeDaLa._internal(source);
    }

    return DeDaLa._internal(
      // TODO: We can forceunwrap here
      CacheConnection.fromPolicy(
        first: _cache!,
        second: source,
        readPolicy: readPolicy!,
        insertPolicy: insertPolicy!,
      ),
    );
  }

  @override
  Stream<V> get(K key) {
    assert(_cache != null, "Empty DeDaLa.");
    return NudgeCache<K, V>(_cache!).get(key);
  }

  @override
  Stream<V> set(K key, V value) {
    assert(_cache != null, "Empty DeDaLa.");
    return _cache!.set(key, value);
  }
}
