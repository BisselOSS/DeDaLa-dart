class Optional<T> {
  final T value;

  Optional(this.value);

  bool get isPresent => value != null;
}
