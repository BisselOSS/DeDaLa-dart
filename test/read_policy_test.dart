import 'dart:async';

import 'package:dedala_dart/src/de_da_la.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:dedala_dart/src/util/functions.dart';
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
              readPolicy: ReadPolicy.IfDownstreamEmpty(),
              readFrom: (id) => Observable.just("Hey there"));

      expect(deDaLa.get(0), emitsInOrder(<String>["Hey there"]));
    });

    test('Does not read second cache if previous cache has content', () {
      var deDaLa = DeDaLa<int, String>()
          .connect(readFrom: (id) => Observable<String>.just("some result"))
          .connect(
              readPolicy: ReadPolicy.IfDownstreamEmpty(),
              readFrom: (id) => Observable.just("Hey there"));

      expect(deDaLa.get(0), emits("some result"));
    });
  });

  group('Gated ReadPolicy', () {
    test('Only emits every 200 milliseconds', () {
      var requestIndex = -1;
      var requestValues = ["First", "Second", "Third"];
      var lastNow = DateTime.fromMillisecondsSinceEpoch(0);
      var gatedDuration = Duration(milliseconds: 200);

      var deDaLa = DeDaLa<int, String>()
          .connect(
            readFrom: (id) => Observable.just(null),
          )
          .connect(
              readPolicy: ReadPolicy.Gated(duration: gatedDuration),
              readFrom: (id) {
                return Observable.just(true).doOnData((_) {
                  var diff = DateTime.now().difference(lastNow).inMilliseconds;
                  lastNow = DateTime.now();

                  print("diff to last request: $diff");
                  expect(diff >= gatedDuration.inMilliseconds, true);
                }).flatMap((_) {
                  requestIndex++;
                  var requestValue = requestValues[requestIndex];
                  return Observable<String>.just(requestValue);
                });
              });

      var publisher = PublishSubject<String>();

      Future(() {
        // return "first"
        deDaLa.get(0).listen(publisher.add);
        // returns "first" -> gate is closed
        deDaLa.get(0).listen(publisher.add);
      })
          .then((_) => Future.delayed(gatedDuration, () {
                // returns "second" -> gate is open after delay
                deDaLa.get(0).listen(publisher.add);

                // returns "second" -> gate is closed again
                deDaLa.get(0).listen(publisher.add);
              }))
          .then((_) => Future.delayed(gatedDuration, () {
                // returns "third" -> gate is open after delay
                deDaLa.get(0).listen(publisher.add);
                // returns "third" -> gate is closed again
                deDaLa.get(0).listen(publisher.add);
                // returns "third" -> gate should still be closed
                deDaLa.get(0).listen(publisher.add);
              }));

      expect(
          publisher.stream.where(notNull).doOnData(print),
          emitsInOrder(<String>[
            "First",
            "First",
            "Second",
            "Second",
            "Third",
            "Third",
            "Third",
          ]));
    });
  });
}
