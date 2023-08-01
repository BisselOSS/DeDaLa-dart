abstract class Cache<K, V> {
  Cache() {
    if (K == dynamic || V == dynamic) {
      throw Exception("K,V can not be dynamic");
    }
  }

  Stream<V> get(K key);

  Stream<V> set(K key, V value);
}
