import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/update_policy.dart';

/**
 * Always updates by ignoring the item
 */
class AlwaysInsertPolicy<T> implements InsertPolicy<T> {
  AlwaysInsertPolicy();

  @override
  UpdateCondition<T> get insertCondition => (Optional<T> item) => true;
}
