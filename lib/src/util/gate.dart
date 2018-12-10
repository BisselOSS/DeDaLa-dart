import 'dart:async';

class Gate {
  final Duration duration;

  bool _isOpen;

  Gate(this.duration, {bool isOpen = false}) : _isOpen = isOpen;

  int lastOpen = 0;

  bool get isOpen => _isOpen;

  bool get isClosed => !_isOpen;

  void close() {
    _isOpen = false;
    Timer(duration, () {
      _isOpen = true;
    });
  }
}
