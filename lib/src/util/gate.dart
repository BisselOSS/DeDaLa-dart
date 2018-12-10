class Gate {
  final Duration duration;

  Gate(this.duration);

  int lastOpen = 0;

  bool get isOpen {
    var now = DateTime.now().millisecond;
    return now - lastOpen > duration.inMilliseconds;
  }

  bool get isClosed => !isOpen;

  void open() {
    lastOpen = DateTime.now().millisecond;
  }
}
