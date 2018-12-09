import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/insert_policy.dart';
import 'package:rxdart/rxdart.dart';

abstract class InsertConnector<K, V> {
  Observable<V> set(K key, V value);
}

class PolicyDrivenInsertConnector<K, V> implements InsertConnector<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;

  final InsertPolicy<V> insertPolicy;

  PolicyDrivenInsertConnector(this.first, this.second, this.insertPolicy);

  @override
  Observable<V> set(K key, V value) {
    var shouldInsert = insertPolicy.insertCondition(Optional(value));

    var finalObservable = Observable.just<void>("");
    if (shouldInsert) {
      //start with the second since we are now going up again
      finalObservable = second.set(key, value);
    }

    return finalObservable.flatMap((_) => first.set(key, value));
  }
}
