import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/caches/memory_cache.dart';
import 'package:dedala_dart/src/de_da_la.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:rxdart/rxdart.dart';

class Playground<K, V> {
  void play() {
    var api = Api<V>();

    //TODO find better naming "upstream", "downstream"

    DeDaLa<K, V>()
        .connect(
            readFrom: (key) => api.requestStuff(),
            readPolicy: ReadPolicy.Gated(duration: Duration(milliseconds: 700)))
        .connectCache(
            source: MemoryCache(),
            insertPolicy: InsertPolicy.Always(),
            readPolicy: ReadPolicy.IfEmpty())
        .connectCache(source: Database());
  }
}

class Database<K, V> implements Cache<K, V> {
  Map<K, V> _map = Map<K, V>();

  @override
  Observable<V> get(K key) => Observable.just(_map[key]);

  @override
  Observable<V> set(K key, V value) {
    _map[key] = value;
    return Observable.just(value);
  }
}

class Api<V> {
  Observable<V> requestStuff() => throw Exception("not implemented");
}
