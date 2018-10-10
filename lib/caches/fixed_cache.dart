import 'package:dedala_dart/cache.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

typedef Observable<V> FixedGet<V>();
typedef Observable FixedSet<V>(V value);

@immutable
class FixedCache<K, V> implements Cache<K, V> {
  final FixedGet<V> readFrom;
  final FixedSet<V> insertTo;
  final String name;

  FixedCache({@required this.readFrom, @required this.insertTo, this.name});

  @override
  Observable<V> get(K key) => readFrom();

  @override
  Observable<void> set(K key, V value) => insertTo(value);
}
