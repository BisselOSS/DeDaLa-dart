import 'package:dedala_dart/cache.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

typedef Observable<V> Get<K, V>(K key);
typedef Observable Set<K, V>(K key, V value);

@immutable
class LambdaCache<K, V> implements Cache<K, V> {
  final Get<K, V> readFrom;
  final Set<K, V> insertTo;

  LambdaCache({@required this.readFrom, @required this.insertTo});

  @override
  Observable<V> get(K key) => readFrom(key);

  @override
  Observable<void> set(K key, V value) => insertTo(key, value);
}
