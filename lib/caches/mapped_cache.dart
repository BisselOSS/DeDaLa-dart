import 'package:dedala_dart/cache.dart';
import 'package:rxdart/rxdart.dart';

/// A Function that converts type T to S
typedef S Transform<S, T>(T value);

/// Mapped Caches can be used whenever the Value has to change between two caches
/// therefore two transformations for both directions is done
class MappedCache<K, From, To> implements Cache<K, To> {
  Transform<To, From> _transform;
  Transform<From, To> _transformInverse;
  Cache<K, From> _first;

  MappedCache(this._first, this._transform, this._transformInverse);

  @override
  Observable<To> get(K key) =>
      _first.get(key).map((value) => this._transform(value));

  @override
  Observable set(K key, To value) =>
      _first.set(key, this._transformInverse(value));
}
