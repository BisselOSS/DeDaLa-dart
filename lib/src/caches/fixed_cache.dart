import 'package:dedala_dart/src/cache.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

typedef Observable<V> FixedGet<V>();
typedef Observable<V> FixedSet<K, V>(V value);

@immutable
class FixedCache<K, V> implements Cache<K, V> {
  final FixedGet<V> readFrom;
  final FixedSet<K, V> insertTo;
  final String name;

  FixedCache({@required this.readFrom, @required this.insertTo, this.name});

  @override
  Observable<V> get(K key) => readFrom();

  @override
  Observable<V> set(K key, V value) => insertTo(value);
}
