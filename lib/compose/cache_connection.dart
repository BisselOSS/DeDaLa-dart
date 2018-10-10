import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:dedala_dart/policy/update_policy.dart';
import 'package:rxdart/rxdart.dart';

class CacheConnection<K, V> implements Cache<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;

  final ReadPolicy<V> readPolicy;
  final InsertPolicy<V> insertPolicy;

  CacheConnection(this.first, this.second, this.readPolicy, this.insertPolicy);

  @override
  Observable<V> get(K key) => first.get(key).map(box).flatMap((optional) {
        var shouldRead = readPolicy.readCondition(optional);
        if (shouldRead) {
          return second.get(key).map(box);
        }

        return Observable.just(optional);
      }).map(unbox);

  @override
  Observable<void> set(K key, V value) {
    var shouldInsert = insertPolicy.insertCondition(Optional(value));

    var finalObservable = Observable.just<void>("");
    if (shouldInsert) {
      //start with the second since we are now going up again
      finalObservable = second.set(key, value);
    }

    return finalObservable.flatMap((_) => first.set(key, value));
  }
}
