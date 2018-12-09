import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read/read_policy.dart';
import 'package:meta/meta.dart';

@immutable
class NeverReadPolicy<T> implements ReadPolicy<T> {
  NeverReadPolicy();

  @override
  ReadCondition<T> get readCondition => (Optional<T> item) => false;
}
