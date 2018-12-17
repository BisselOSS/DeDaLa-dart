import 'package:dedala_dart/src/de_da_la.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:rxdart/rxdart.dart';

import '../test/model/user.dart';

void main() {
  var api = UserApi();
  var repository = UserRepository();

  DeDaLa<int, User>()
      .connect(
          readPolicy: ReadPolicy.Always(),
          readFrom: (id) => repository.getUser(id))
      .connect(
          readPolicy: ReadPolicy.IfDownstreamEmpty(),
          readFrom: (id) => api.requestUser(id));
}

class UserApi {
  Observable<User> requestUser(int id) =>
      Observable.just(User(name: "😎", email: "cool@dude.com"));
}

class UserRepository {
  Observable<User> getUser(int id) => Observable.just(null);

  Observable<User> insertUser(User user) {
    _insertIntoDatabase(user);
    // returns the inserted item
    return Observable.just(user);
  }

  void _insertIntoDatabase(User user) {
    //somebody implement a database here 😡
  }
}
