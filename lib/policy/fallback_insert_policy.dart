import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/update_policy.dart';

/**
 * Only updates if the value is present
 */
class FallbackInsertPolicy<T> implements InsertPolicy<T> {
  const FallbackInsertPolicy();

  @override
  UpdateCondition<T> get insertCondition =>
      (Optional<T> item) => item.isPresent;
}
