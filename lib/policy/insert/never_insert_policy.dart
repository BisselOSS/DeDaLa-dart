import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/insert/insert_policy.dart';

/**
 * Never updates
 */
class NeverInsertPolicy<T> implements InsertPolicy<T> {
  const NeverInsertPolicy();

  @override
  InsertCondition<T> get insertCondition => (Optional<T> item) => false;
}
