import 'dart:async';

import 'package:dedala_dart/src/de_da_la.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:dedala_dart/src/util/functions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'model/mock.dart';
import 'model/user.dart';

void main() {
  test('Always ReadPolicy - Emits always and in correct order', () {
    var userCount = 3;
    var users = mockedUsers.take(userCount).toList();
    var userId = 5;

    var deDaLa = DeDaLa<int, List<User>>()
        .connect(
            readPolicy: ReadPolicy.Always(),
            readFrom: (id) =>
                Stream.just(users).delay(Duration(milliseconds: 20)))
        .connect(
            readPolicy: ReadPolicy.Always(),
            readFrom: (id) => Stream.just(List()));

    var request = deDaLa.get(userId).map((users) => users.length);

    expect(request, emitsInOrder(<int>[userCount, 0]));
  });

  test('IfEmpty ReadPolicy - Reads second cache if previous cache was empty',
      () {
    var deDaLa = DeDaLa<int, String>()
        .connect(readFrom: (id) => Stream<String>.just(null))
        .connect(
            readPolicy: ReadPolicy.IfDownstreamEmpty(),
            readFrom: (id) => Stream.just("Hey there"));

    expect(deDaLa.get(0), emitsInOrder(<String>["Hey there"]));
  });

  test('Does not read second cache if previous cache has content', () {
    var deDaLa = DeDaLa<int, String>()
        .connect(readFrom: (id) => Stream<String>.just("some result"))
        .connect(
            readPolicy: ReadPolicy.IfDownstreamEmpty(),
            readFrom: (id) => Stream.just("Hey there"));

    expect(deDaLa.get(0), emits("some result"));
  });

  test('Gated ReadPolicy - Only emits every 200 milliseconds', () {
    var requestIndex = -1;
    var requestValues = ["First", "Second", "Third"];
    var lastNow = DateTime.fromMillisecondsSinceEpoch(0);
    var gatedDuration = Duration(milliseconds: 200);

    var deDaLa = DeDaLa<int, String>()
        .connect(
          readFrom: (id) => Stream.just(null),
        )
        .connect(
            readPolicy: ReadPolicy.Gated(duration: gatedDuration),
            readFrom: (id) {
              return Stream.just(true).doOnData((_) {
                var diff = DateTime.now().difference(lastNow).inMilliseconds;
                lastNow = DateTime.now();

                print("diff to last request: $diff");
                expect(diff >= gatedDuration.inMilliseconds, true);
              }).flatMap((_) {
                requestIndex++;
                var requestValue = requestValues[requestIndex];
                return Stream<String>.just(requestValue);
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
}
