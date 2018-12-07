import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/caches/memory_cache.dart';
import 'package:dedala_dart/de_da_la.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:dedala_dart/policy/update_policy.dart';
import 'package:rxdart/rxdart.dart';

class Playground<K, V> {
  void play() {
    var api = Api<V>();

    DeDaLa<K, V>()
        .connect(
            readFrom: (key) => api.requestStuff(),
            readPolicy: ReadPolicy.Gated(duration: Duration(milliseconds: 700)))
        .connectCache(
            source: MemoryCache(),
            insertPolicy: InsertPolicy.Always(),
            readPolicy: ReadPolicy.Fallback())
        .connectCache(source: Database());
  }
}

class Database<K, V> implements Cache<K, V> {
  Map<K, V> _map = Map<K, V>();

  @override
  Observable<V> get(K key) => Observable.just(_map[key]);

  @override
  Observable<void> set(K key, V value) {
    _map[key] = value;
    return Observable.just(value);
  }
}

class Api<V> {
  Observable<V> requestStuff() => throw Exception("not implemented");
}
