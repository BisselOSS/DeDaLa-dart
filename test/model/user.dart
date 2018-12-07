import 'package:meta/meta.dart';

class User {
  final String name;
  final String email;
  final DateTime createdAt;

  User({@required this.name, @required this.email, DateTime createdAt})
      : createdAt = createdAt ?? DateTime.now();
}
