import 'package:dedala_dart/src/cache.dart';
import 'package:meta/meta.dart';

@immutable
class MemoryCache<K, V> implements Cache<K, V?> {
  final _map = <K, V?>{};

  @override
  Stream<V?> get(K key) => Stream.value(_map[key]);

  @override
  Stream<V?> set(K key, V? value) {
    _map[key] = value;
    return Stream.value(value);
  }
}
