import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/insert/insert_policy.dart';

/**
 * Only updates if the value is present
 */
class IfEmptyInsertPolicy<T> implements InsertPolicy<T> {
  const IfEmptyInsertPolicy();

  @override
  InsertCondition<T> get insertCondition =>
      (Optional<T> item) => item.isPresent;
}
