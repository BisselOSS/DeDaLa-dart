import 'package:dedala_dart/optional.dart';
import 'package:dedala_dart/policy/always_read_policy.dart';
import 'package:dedala_dart/policy/fallback_read_policy.dart';
import 'package:dedala_dart/policy/gated_read_policy.dart';
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

  static ReadPolicy<T> Fallback<T>() => FallbackReadPolicy();
}
