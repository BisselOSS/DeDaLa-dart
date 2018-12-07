import 'package:dedala_dart/cache.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/src/observables/observable.dart';

@immutable
class EmptyCache<K, V> implements Cache<K, V> {
  @override
  Observable<V> get(K key) => Observable.just(null);

  @override
  Observable<void> set(K key, V value) => Observable.just(value);
}
