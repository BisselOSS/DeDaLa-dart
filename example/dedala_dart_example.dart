import 'package:dedala_dart/src/de_da_la.dart';
import 'package:dedala_dart/src/policy/insert_policy.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';

import '../test/model/user.dart';

void main() {
  final api = UserApi();
  final repository = UserRepository();

  final userDeDaLa = DeDaLa<int, User>()
      .connect(
          readPolicy: ReadPolicy.Always(),
          readFrom: (id) => repository.getUser(id),
          insertPolicy: InsertPolicy.Always(),
          insertTo: (int id, User user) => repository.insertUser(user))
      .connect(
        readPolicy: ReadPolicy.IfDownstreamEmpty(),
        readFrom: (id) => api.requestUser(id),
      );

  const myUserId = 5;
  userDeDaLa.get(myUserId).listen((user) {
    //handle result
    print(user.email);
  });
}

class UserApi {
  Stream<User> requestUser(int id) =>
      Stream.value(User(name: "😎", email: "cool@dude.com"));
}

class UserRepository {
  Stream<User> getUser(int id) =>
      Stream.value(User(name: "Cool Dude", email: "cool@dude.com"));

  Stream<User> insertUser(User user) {
    _insertIntoDatabase(user);
    // returns the inserted item
    return Stream.value(user);
  }

  void _insertIntoDatabase(User user) {
    // do your database stuff here 🤔
  }
}
