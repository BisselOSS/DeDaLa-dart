import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:rxdart/rxdart.dart';

abstract class InsertConnector<K, V> {
  Stream<V?> set(K key, V? value);
}

class ConditionalInsertConnector<K, V> implements InsertConnector<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;

  final InsertCondition<V> insertCondition;

  ConditionalInsertConnector(this.first, this.second, this.insertCondition);

  @override
  Stream<V?> set(K key, V? value) {
    var shouldInsert = insertCondition(value);

    var finalStream = Stream.value(value);
    if (shouldInsert) {
      //start with the second since we are now going up again
      finalStream = second.set(key, value);
    }

    return finalStream.flatMap((_) => first.set(key, value));
  }
}
