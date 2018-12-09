import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/insert/always_insert_policy.dart';
import 'package:dedala_dart/policy/insert/fallback_insert_policy.dart';
import 'package:dedala_dart/policy/insert/never_insert_policy.dart';

/**
 * Decides if the cache should be updated
 */
typedef bool InsertCondition<T>(Optional<T> item);

abstract class InsertPolicy<T> {
  final InsertCondition<T> insertCondition;

  InsertPolicy(this.insertCondition);

  static InsertPolicy<T> Always<T>() => AlwaysInsertPolicy<T>();

  static InsertPolicy<T> Never<T>() => NeverInsertPolicy<T>();

  static InsertPolicy<T> IfEmpty<T>() => IfEmptyInsertPolicy<T>();
}
