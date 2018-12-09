import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/read/always_read_policy.dart';
import 'package:dedala_dart/policy/read/fallback_read_policy.dart';
import 'package:dedala_dart/policy/read/gated_read_policy.dart';
import 'package:dedala_dart/policy/read/never_read_policy.dart';
import 'package:meta/meta.dart';

/**
 * Decides if the cache should be read.
 */
typedef bool ReadCondition<T>(Optional<T> item);

abstract class ReadPolicy<T> {
  final ReadCondition<T> readCondition;

  ReadPolicy(this.readCondition);

  static ReadPolicy<T> Always<T>() => AlwaysReadPolicy<T>();

  static ReadPolicy<T> Gated<T>({@required Duration duration}) =>
      GatedReadPolicy<T>(duration);

  static ReadPolicy<T> IfEmpty<T>() => IfEmptyReadPolicy();

  static ReadPolicy<T> Never<T>() => NeverReadPolicy<T>();
}
