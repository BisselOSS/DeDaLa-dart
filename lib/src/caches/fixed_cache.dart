import 'package:dedala_dart/src/cache.dart';
import 'package:meta/meta.dart';

typedef FixedGet<V> = Stream<V> Function();
typedef FixedSet<K, V> = Stream<V> Function(V? value);

@immutable
class FixedCache<K, V> implements Cache<K, V> {
  final FixedGet<V> readFrom;
  final FixedSet<K, V> insertTo;
  final String? name;

  const FixedCache({
    required this.readFrom,
    required this.insertTo,
    this.name,
  });

  @override
  Stream<V> get(K key) => readFrom();

  @override
  Stream<V> set(K key, V? value) => insertTo(value);
}
