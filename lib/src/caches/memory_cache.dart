import 'package:dedala_dart/src/cache.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class MemoryCache<K, V> implements Cache<K, V> {
  final Map<K, V> _map = Map<K, V>();

  @override
  Observable<V> get(K key) => Observable.just(_map[key]);

  @override
  Observable<V> set(K key, V value) {
    _map[key] = value;
    return Observable.just(value);
  }
}
