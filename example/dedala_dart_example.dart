import 'package:dedala_dart/src/caches/memory_cache.dart';
import 'package:dedala_dart/src/de_da_la.dart';
import 'package:dedala_dart/src/policy/read_policy.dart';
import 'package:rxdart/rxdart.dart';

import '../test/model/user.dart';

void main() {
  var api = UserApi();
  var memoryCache = MemoryCache<int, User>();
  var database = UserRepository();

  var myUserId = 5;

  var userDeDaLa = DeDaLa<int, User>()
      .connectCache(source: memoryCache)
      .connect(
          readFrom: (id) => database.getUser(id),
          readPolicy: ReadPolicy.IfDownstreamEmpty(),
          insertTo: (int id, User user) => database.insertUser(user))
      .connect(
          readFrom: (id) => api.requestUser(id),
          readPolicy: ReadPolicy.Gated(duration: Duration(minutes: 1)));

  userDeDaLa.get(myUserId).listen((user) {
    // handle result
  });

  memoryCache.get(myUserId).flatMap<User>((user) {
    // cache is empty
    if (user == null) {
      // check if the database has something
      return database.getUser(myUserId).flatMap((user) {
        // database is empty or last request was more than 1 minute ago
        if (user == null || _isDataExpired(minutes: 1)) {
          // request data from the api
          return api.requestUser(myUserId).flatMap((user) {
            // insert the data
            return memoryCache
                .set(myUserId, user)
                .flatMap((_) => database.insertUser(user));
          });
        } else {
          return Observable.just(user);
        }
      });
    } else {
      return Observable.just(user);
    }
  });
}

bool _isDataExpired({int minutes}) => true;

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
    // do your database stuff here 🤔
  }
}
