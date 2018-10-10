import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/always_insert_policy.dart';
import 'package:dedala_dart/policy/fallback_insert_policy.dart';
import 'package:dedala_dart/policy/never_insert_policy.dart';

/**
 * Decides if the cache should be updated
 */
typedef bool UpdateCondition<T>(Optional<T> item);

abstract class InsertPolicy<T> {
  final UpdateCondition<T> insertCondition;

  InsertPolicy(this.insertCondition);

  static InsertPolicy<T> Always<T>() => AlwaysInsertPolicy<T>();

  static InsertPolicy<T> Never<T>() => NeverInsertPolicy<T>();

  static InsertPolicy<T> Fallback<T>() => FallbackInsertPolicy<T>();
}
