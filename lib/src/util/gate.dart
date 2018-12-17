import 'dart:async';

class Gate {
  final Duration duration;

  bool _isOpen;

  Gate(this.duration, {bool initialValue = false}) : _isOpen = initialValue;

  bool get isOpen => _isOpen;

  bool get isClosed => !_isOpen;

  void close() {
    _isOpen = false;
    Timer(duration, () {
      _isOpen = true;
    });
  }
}
