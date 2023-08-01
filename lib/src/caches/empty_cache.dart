import 'package:meta/meta.dart';

import '../cache.dart';

@immutable
class EmptyCache<K, V> implements Cache<K, V?> {
  @override
  Stream<V?> get(K key) => Stream.value(null);

  @override
  Stream<V?> set(K key, V? value) => Stream.value(value);
}
