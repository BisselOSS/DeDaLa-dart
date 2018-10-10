import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:meta/meta.dart';

@immutable
class FallbackReadPolicy<T> implements ReadPolicy<T> {
  FallbackReadPolicy();

  @override
  ReadCondition<T> get readCondition => (Optional<T> item) => !item.isPresent;
}
