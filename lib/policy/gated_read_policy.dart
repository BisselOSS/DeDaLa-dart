import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:meta/meta.dart';

@immutable
class GatedReadPolicy<T> implements ReadPolicy<T> {
  final Gate gate;

  GatedReadPolicy(Duration duration) : gate = Gate(duration);

  @override
  ReadCondition<T> get readCondition => (Optional<T> item) {
        if (!gate.isOpen) return false;

        gate.open();
        return true;
      };
}

class Gate {
  final Duration duration;

  Gate(this.duration);

  int lastOpen = 0;

  bool get isOpen {
    var now = DateTime.now().millisecond;
    return now - lastOpen > duration.inMilliseconds;
  }

  void open() {
    lastOpen = DateTime.now().millisecond;
  }
}
