import 'package:dedala_dart/optional.dart';
import 'package:meta/meta.dart';

/**
 * Decides if the cache should be updated
 */
typedef bool InsertCondition<T>(Optional<T> item);

class InsertPolicy<T> {
  final InsertCondition<T> insertCondition;

  InsertPolicy({@required this.insertCondition});

  static InsertPolicy<T> Always<T>() =>
      InsertPolicy(insertCondition: (optional) => true);

  static InsertPolicy<T> Never<T>() =>
      InsertPolicy(insertCondition: (optional) => false);

  static InsertPolicy<T> IfEmpty<T>() =>
      InsertPolicy(insertCondition: (optional) => optional.isNotPresent);
}
