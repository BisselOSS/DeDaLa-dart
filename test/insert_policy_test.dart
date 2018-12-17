import 'package:dedala_dart/src/de_da_la.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'model/user.dart';

void main() {
  group('Insert InsertPolicy', () {
    test("Inserts in correct order", () {
      var testUser1 = User(name: "testuser1", email: "1@test.com");
      var testUser2 = User(name: "some name", email: "2@test.com");
      List<User> userList = List();

      DeDaLa<int, User>()
          .connect(
            readFrom: (id) => Observable.just(testUser1),
          )
          .connect(
            readFrom: (id) => Observable.just(testUser2),
          )
          .connect(
              insertPolicy: InsertPolicy.Always(),
              insertTo: (int id, User user) {
                userList.add(user);
                return Observable.just(user);
              })
          .get(0)
          .listen((user) {
        expect(userList.length, 2);
        expect(userList[0], testUser1);
        expect(userList[1], testUser2);
      });
    });
  });

  group('Never InsertPolicy', () {
    test("inserts never", () {
      var testUser1 = User(name: "testuser1", email: "1@test.com");
      List<User> userList = List();

      DeDaLa<int, User>()
          .connect(
            readFrom: (id) => Observable.just(testUser1),
          )
          .connect(
            readFrom: (id) => Observable.just(testUser1),
          )
          .connect(
              insertPolicy: InsertPolicy.Never(),
              insertTo: (int id, User user) {
                throw Exception(
                    "function should not be called if insert policy is \"Never\"");
              })
          .get(0)
          .listen((user) {
        expect(userList.length, 0);
      });
    });
  });

  group('IfUpstreamNotEmpty InsertPolicy', () {
    test("inserts not null values", () {
      var testUser1 = User(name: "testuser1", email: "1@test.com");
      List<User> userList = List();

      DeDaLa<int, User>()
          .connect(
            readFrom: (id) => Observable.just(null),
          )
          .connect(
            readFrom: (id) => Observable.just(testUser1),
          )
          .connect(
              insertPolicy: InsertPolicy.IfUpstreamNotEmpty(),
              insertTo: (int id, User user) {
                userList.add(user);
                return Observable.just(user);
              })
          .get(0)
          .listen((user) {
        expect(userList.length, 1);
        expect(userList[1], testUser1);
      });
    });
  });

  group('IfUpstreamEmpty InsertPolicy', () {
    test("inserts null values only", () {
      var testUser1 = User(name: "testuser1", email: "1@test.com");
      List<User> userList = List();

      DeDaLa<int, User>()
          .connect(
            readFrom: (id) => Observable.just(null),
          )
          .connect(
            readFrom: (id) => Observable.just(testUser1),
          )
          .connect(
              insertPolicy: InsertPolicy.IfUpstreamEmpty(),
              insertTo: (int id, User user) {
                userList.add(user);
                return Observable.just(user);
              })
          .get(0)
          .listen((user) {
        expect(userList.length, 1);
        expect(userList[1], null);
      });
    });
  });
}
