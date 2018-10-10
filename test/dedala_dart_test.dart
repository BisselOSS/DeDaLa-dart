import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/caches/memory_cache.dart';
import 'package:dedala_dart/de_da_la.dart';
import 'package:dedala_dart/dedala_dart.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:dedala_dart/policy/update_policy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class Playground<K, V> {
  void play() {
    var api = Api<V>();

    DeDaLa<K, V>()
        .connect(
            readFrom: () => api.requestStuff(),
            insertTo: (updateData) => api.updateEntity(updateData),
            readPolicy: ReadPolicy.Gated(duration: Duration(milliseconds: 700)))
        .connectCache(
            source: MemoryCache(),
            insertPolicy: InsertPolicy.Always(),
            readPolicy: ReadPolicy.Fallback())
        .connectCache(source: Database());
  }
}

void main() {
  group('A group of tests', () {
    Awesome awesome;

    setUp(() {
      awesome = Awesome();
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}

//TODO remove example classes

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

  Observable<V> updateEntity(V some) => throw Exception("not implemented");
}
