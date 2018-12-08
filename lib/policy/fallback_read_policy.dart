import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:meta/meta.dart';

@immutable
class IfEmptyReadPolicy<T> implements ReadPolicy<T> {
  IfEmptyReadPolicy();

  @override
  ReadCondition<T> get readCondition => (Optional<T> item) => !item.isPresent;
}
