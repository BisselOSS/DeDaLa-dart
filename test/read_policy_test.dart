import 'package:dedala_dart/de_da_la.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'model/mock.dart';
import 'model/user.dart';

void main() {
  group('A group of tests', () {
    test('Always <-> Always: emits twice and in correct order', () {
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

    test('IfEmpty: reads second cache if previous cache was empty', () {
      var deDaLa = DeDaLa<int, String>()
          .connect(readFrom: (id) => Observable<String>.just(null))
          .connect(
              readPolicy: ReadPolicy.IfEmpty(),
              readFrom: (id) => Observable.just("Hey there"));

      expect(deDaLa.get(0), emitsInOrder(<String>[null, "Hey there"]));
    });

    test('IfEmpty: does not read second cache if previous cache has content',
        () {
      var deDaLa = DeDaLa<int, String>()
          .connect(readFrom: (id) => Observable<String>.just("some result"))
          .connect(
              readPolicy: ReadPolicy.IfEmpty(),
              readFrom: (id) => Observable.just("Hey there"));

      expect(deDaLa.get(0), emits("some result"));
    });
  });
}
