import 'package:dedala_dart/de_da_la.dart';
import 'package:dedala_dart/policy/read_policy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'model/mock.dart';
import 'model/user.dart';

void main() {
  group('A group of tests', () {
    test('Simple get return in correct order', () {
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
}
