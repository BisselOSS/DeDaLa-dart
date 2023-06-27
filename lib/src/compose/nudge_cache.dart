import 'package:dedala_dart/src/cache.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class NudgeCache<K, V> implements Cache<K, V> {
  final Cache<K, V> sourceCache;

  NudgeCache(this.sourceCache);

  @override
  Stream<V?> get(K key) => sourceCache
      .get(key)
      .flatMap((value) => set(key, value).map((_) => value));

  @override
  Stream<V?> set(K key, V? value) => sourceCache.set(key, value);
}
