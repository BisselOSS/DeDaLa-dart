import 'package:dedala_dart/cache.dart';
import 'package:dedala_dart/compose/cache_connection_controller.dart';
import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:dedala_dart/util/functions.dart';
import 'package:rxdart/rxdart.dart';

abstract class ReadConnector<K, V> {
  Observable<V> get(K key);
}

class PolicyDrivenReadConnector<K, V> implements ReadConnector<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;

  final ReadPolicy<V> readPolicy;

  PolicyDrivenReadConnector(this.first, this.second, this.readPolicy);

  @override
  Observable<V> get(K key) =>
      CacheConnectionController<Optional<V>>(onStart: (env) {
        env.addSubscription(
          first.get(key).map(box).listen((event) {
            env.add(event);

            var shouldRead = readPolicy.readCondition(event);

            if (shouldRead) {
              env.addSubscription(
                second.get(key).map(box).listen((event2) {
                  env.add(event2);
                }),
              );
            }
          }),
        );
      }).stream.map(unbox);
}
