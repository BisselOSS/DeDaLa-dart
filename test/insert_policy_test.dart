import 'package:dedala_dart/src/de_da_la.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:test/test.dart';

import 'model/user.dart';

void main() {
  test("Insert InsertPolicy - Inserts in correct order", () async {
    final testUser1 = User(name: "testuser1", email: "1@test.com");
    final testUser2 = User(name: "some name", email: "2@test.com");
    final userList = <User>[];

    await DeDaLa<int, User>()
        .connect(readFrom: (id) => Stream.value(testUser1))
        .connect(readFrom: (id) => Stream.value(testUser2))
        .connect(
            insertPolicy: InsertPolicy.Always(),
            insertTo: (int id, User user) {
              userList.add(user);
              return Stream.value(user);
            })
        .get(0)
        .first;

    expect(userList.length, 2);
    expect(userList[0], testUser1);
    expect(userList[1], testUser2);
  });

  test("Never InsertPolicy - inserts never", () async {
    final testUser1 = User(name: "testuser1", email: "1@test.com");
    final userList = <User>[];

    await DeDaLa<int, User>()
        .connect(
          readFrom: (id) => Stream.value(testUser1),
        )
        .connect(
          readFrom: (id) => Stream.value(testUser1),
        )
        .connect(
            insertPolicy: InsertPolicy.Never(),
            insertTo: (int id, User user) {
              throw Exception(
                "function should not be called if insert policy is \"Never\"",
              );
            })
        .get(0)
        .first;

    expect(userList.length, 0);
  });

  test("IfUpstreamNotEmpty InsertPolicy - inserts not null values", () {
    final testUser1 = User(name: "testuser1", email: "1@test.com");
    final userList = <User>[];

    final observable = DeDaLa<int, User?>()
        .connect(readFrom: (id) => Stream.value(null))
        .connect(readFrom: (id) => Stream.value(testUser1))
        .connect(
            insertPolicy: InsertPolicy.IfUpstreamNotEmpty(),
            insertTo: (int id, user) {
              assert(userList.isEmpty, "Should not be called.");

              userList.add(user!);
              return Stream.value(user);
            })
        .get(0)
        .map((_) => userList);

    expect(observable, emits([testUser1]));
  });

  test("IfUpstreamEmpty InsertPolicy - inserts null values only", () {
    final testUser1 = User(name: "testuser1", email: "1@test.com");
    final userList = <User>[];

    final observable = DeDaLa<int, User?>()
        .connect(
          readFrom: (id) => Stream.value(null),
        )
        .connect(
          readFrom: (id) => Stream.value(testUser1),
        )
        .connect(
            insertPolicy: InsertPolicy.IfUpstreamEmpty(),
            insertTo: (int id, user) {
              userList.add(user!);
              return Stream.value(user);
            })
        .get(0)
        .map((_) => userList);

    expect(observable, emits([null]));
  });
}
