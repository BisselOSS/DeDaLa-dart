import 'package:dedala_dart/optional.dart';
import 'package:meta/meta.dart';

/**
 * Decides if the cache should be read.
 */
typedef bool ReadCondition<T>(Optional<T> item);

class ReadPolicy<T> {
  final ReadCondition<T> readCondition;

  ReadPolicy({@required this.readCondition});

  static ReadPolicy<T> Always<T>() =>
      ReadPolicy(readCondition: (optional) => true);

  static ReadPolicy<T> Gated<T>({@required Duration duration}) =>
      _GatedReadPolicy(duration);

  static ReadPolicy<T> IfEmpty<T>() =>
      ReadPolicy(readCondition: (optional) => optional.isNotPresent);

  static ReadPolicy<T> Never<T>() =>
      ReadPolicy(readCondition: (optional) => false);
}

@immutable
class _GatedReadPolicy<T> implements ReadPolicy<T> {
  final _Gate gate;

  _GatedReadPolicy(Duration duration) : gate = _Gate(duration);

  @override
  ReadCondition<T> get readCondition => (Optional<T> item) {
        if (!gate.isOpen) return false;

        gate.open();
        return true;
      };
}

class _Gate {
  final Duration duration;

  _Gate(this.duration);

  int lastOpen = 0;

  bool get isOpen {
    var now = DateTime.now().millisecond;
    return now - lastOpen > duration.inMilliseconds;
  }

  void open() {
    lastOpen = DateTime.now().millisecond;
  }
}
