class Optional<T> {
  final T value;

  Optional(this.value);

  bool get isPresent => value != null;
}

Optional<V> box<V>(V event) => Optional(event);

V unbox<V>(Optional<V> event) => event.value;
