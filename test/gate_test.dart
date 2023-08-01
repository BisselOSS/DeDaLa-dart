import 'dart:async';

import 'package:dedala_dart/src/util/gate.dart';
import 'package:test/test.dart';

void main() {
  test('Gate opens and closes correctly', () async {
    const initialState = true;
    const duration = Duration(milliseconds: 100);

    final gate = Gate(duration, initialValue: initialState);

    // test initial State
    expect(gate.isOpen, initialState);
    expect(gate.isClosed, !initialState);

    gate.close();
    expect(gate.isOpen, false);
    await Future<void>.delayed(duration);
    expect(gate.isOpen, true);
  });
}
