import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/optional.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:rxdart/rxdart.dart';

abstract class InsertConnector<K, V> {
  Observable<V> set(K key, V value);
}

class ConditionalInsertConnector<K, V> implements InsertConnector<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;

  final InsertCondition<V> insertCondition;

  ConditionalInsertConnector(this.first, this.second, this.insertCondition);

  @override
  Observable<V> set(K key, V value) {
    var shouldInsert = insertCondition(Optional(value));

    var finalObservable = Observable.just<void>("");
    if (shouldInsert) {
      //start with the second since we are now going up again
      finalObservable = second.set(key, value);
    }

    return finalObservable.flatMap((_) => first.set(key, value));
  }
}
