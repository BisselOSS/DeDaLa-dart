import 'dart:async';

import 'package:dedala_dart/src/util/gate.dart';
import 'package:test/test.dart';

void main() {
  test('Gate opens and closes correctly', () {
    var initialState = true;
    var duration = Duration(milliseconds: 100);

    var gate = Gate(duration, initialValue: initialState);

    // test initial State
    expect(gate.isOpen, initialState);
    expect(gate.isClosed, !initialState);

    gate.close();
    expect(gate.isOpen, false);
    Future.delayed(duration, () {
      expect(gate.isOpen, true);
    });
  });
}
