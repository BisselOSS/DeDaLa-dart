import 'package:dedala_dart/src/cache.dart';
import 'package:meta/meta.dart';

typedef Get<K, V> = Stream<V> Function(K key);
typedef Set<K, V> = Stream<V> Function(K key, V value);

@immutable
class LambdaCache<K, V> implements Cache<K, V> {
  final Get<K, V> readFrom;
  final Set<K, V> insertTo;

  const LambdaCache({required this.readFrom, required this.insertTo});

  @override
  Stream<V> get(K key) => readFrom(key);

  @override
  Stream<V> set(K key, V value) => insertTo(key, value);
}
