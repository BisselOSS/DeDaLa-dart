import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/compose/cache_connection_controller.dart';
import 'package:dedala_dart/src/optional.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:dedala_dart/src/util/functions.dart';
import 'package:rxdart/rxdart.dart';

abstract class ReadConnector<K, V> {
  Observable<V> get(K key);
}

class ConditionalReadConnector<K, V> implements ReadConnector<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;

  final ReadCondition<V> readCondition;

  ConditionalReadConnector(this.first, this.second, this.readCondition);

  @override
  Observable<V> get(K key) =>
      CacheConnectionController<Optional<V>>(onStart: (env) {
        env.addCancelable(
          first.get(key).map(box).listen((event) {
            env.add(event);

            var shouldRead = readCondition(event);

            if (shouldRead) {
              env.addCancelable(
                second.get(key).map(box).listen((event2) {
                  env.add(event2);
                }),
              );
            }
          }),
        );
      }).stream.map(unbox);
}
