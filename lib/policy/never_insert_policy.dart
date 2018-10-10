import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/update_policy.dart';

/**
 * Never updates
 */
class NeverInsertPolicy<T> implements InsertPolicy<T> {
  const NeverInsertPolicy();

  @override
  UpdateCondition<T> get insertCondition => (Optional<T> item) => false;
}
