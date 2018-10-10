import 'package:dedala_dart/cache.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

typedef Observable<V> Get<K, V>(K key);
typedef Observable Set<K, V>(K key, V value);

@immutable
class LambdaCache<K, V> implements Cache<K, V> {
  final Get<K, V> getHandler;
  final Set<K, V> setHandler;

  LambdaCache(this.getHandler, this.setHandler);

  @override
  Observable<V> get(K key) => getHandler(key);

  @override
  Observable<void> set(K key, V value) => setHandler(key, value);
}
