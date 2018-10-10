import 'package:rxdart/rxdart.dart';

abstract class Cache<K, V> {
  Cache() {
    if (K == dynamic || V == dynamic) {
      throw Exception("K,V can not be dynamic");
    }
  }

  Observable<V> get(K key);

  Observable<void> set(K key, V value);
}
