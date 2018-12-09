import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read/read_policy.dart';
import 'package:meta/meta.dart';

@immutable
class AlwaysReadPolicy<T> implements ReadPolicy<T> {
  AlwaysReadPolicy();

  @override
  ReadCondition<T> get readCondition => (Optional<T> item) => true;
}
