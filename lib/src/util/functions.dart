import 'package:dedala_dart/src/optional.dart';

Optional<V> box<V>(V event) => Optional(event);

V unbox<V>(Optional<V> event) => event.value;

bool notNull<V>(V event) => event != null;

bool isNull<V>(V event) => event == null;
