import 'package:dedala_dart/src/cache.dart';
import 'package:dedala_dart/src/compose/cache_connection_controller.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';

abstract class ReadConnector<K, V> {
  Stream<V> get(K key);
}

class ConditionalReadConnector<K, V> implements ReadConnector<K, V> {
  final Cache<K, V> first;
  final Cache<K, V> second;

  final ReadCondition<V> readCondition;
  final bool discardPrevious;

  //TODO create event discarder
  ConditionalReadConnector(
    this.first,
    this.second,
    this.readCondition,
    this.discardPrevious,
  );

  @override
  Stream<V> get(K key) => CacheConnectionController<V>(onStart: (env) {
        env.addCancelable(
          first.get(key).listen((event) {
            final shouldRead = readCondition(event);
            final discard = shouldRead && discardPrevious;

            if (!discard) {
              env.add(event);
            }

            if (shouldRead) {
              env.addCancelable(
                second.get(key).listen((event2) {
                  env.add(event2);
                }),
              );
            }
          }),
        );
      }).stream;
}
