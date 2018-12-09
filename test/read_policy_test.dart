import 'dart:async';

import 'package:dedala_dart/de_da_la.dart';
import 'package:dedala_dart/policy/read/read_policy.dart';
import 'package:dedala_dart/util/functions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'model/mock.dart';
import 'model/user.dart';

void main() {
  group('Always ReadPolicy', () {
    test('Emits always and in correct order', () {
      var userCount = 3;
      var users = mockedUsers.take(userCount).toList();
      var userId = 5;

      var deDaLa = DeDaLa<int, List<User>>()
          .connect(
              readPolicy: ReadPolicy.Always(),
              readFrom: (id) =>
                  Observable.just(users).delay(Duration(milliseconds: 20)))
          .connect(
              readPolicy: ReadPolicy.Always(),
              readFrom: (id) => Observable.just(List()));

      var request = deDaLa.get(userId).map((users) => users.length);

      expect(request, emitsInOrder(<int>[userCount, 0]));
    });
  });

  group('IfEmpty ReadPolicy', () {
    test('Reads second cache if previous cache was empty', () {
      var deDaLa = DeDaLa<int, String>()
          .connect(readFrom: (id) => Observable<String>.just(null))
          .connect(
              readPolicy: ReadPolicy.IfEmpty(),
              readFrom: (id) => Observable.just("Hey there"));

      expect(deDaLa.get(0), emitsInOrder(<String>[null, "Hey there"]));
    });

    test('Does not read second cache if previous cache has content', () {
      var deDaLa = DeDaLa<int, String>()
          .connect(readFrom: (id) => Observable<String>.just("some result"))
          .connect(
              readPolicy: ReadPolicy.IfEmpty(),
              readFrom: (id) => Observable.just("Hey there"));

      expect(deDaLa.get(0), emits("some result"));
    });
  });

  group('Gated ReadPolicy', () {
    test('Only emits every 200 milliseconds', () {
      var requestIndex = -1;
      var requestValues = ["First", "Second", "Third"];
      var lastRequestTimeStamp = _nowMillis();

      var deDaLa = DeDaLa<int, String>()
          .connect(
            readFrom: (id) => Observable.just(null),
          )
          .connect(
              readPolicy:
                  ReadPolicy.Gated(duration: Duration(milliseconds: 200)),
              readFrom: (id) {
                expect(lastRequestTimeStamp > 200, true);
                lastRequestTimeStamp = _nowMillis() - lastRequestTimeStamp;

                requestIndex++;
                return Observable<String>.just(requestValues[requestIndex]);
              });

      expect(deDaLa.get(0).where(notNull), emits("First"));
      expect(deDaLa.get(0).where(notNull), emits("First"));

      Future.delayed(Duration(milliseconds: 200), () {
        expect(deDaLa.get(0).where(notNull), emits("Second"));
      });
    });
  });
}

int _nowMillis() => DateTime.now().millisecondsSinceEpoch;
