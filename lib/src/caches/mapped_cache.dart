import 'package:dedala_dart/src/cache.dart';

/// A Function that converts type T to S
typedef S Transform<S, T>(T? value);

/// Mapped Caches can be used whenever the Value has to change between two caches
/// therefore two transformations for both directions is done
class MappedCache<K, From, To> implements Cache<K, To> {
  final Transform<To, From> _transform;
  final Transform<From, To> _transformInverse;
  final Cache<K, From> _first;

  MappedCache(this._first, this._transform, this._transformInverse);

  @override
  Stream<To?> get(K key) =>
      _first.get(key).map((value) => this._transform(value));

  @override
  Stream<To?> set(K key, To? value) =>
      _first.set(key, this._transformInverse(value)).map(_transform);
}
