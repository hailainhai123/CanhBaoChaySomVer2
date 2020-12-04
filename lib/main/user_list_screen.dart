import 'package:flutter/material.dart';
import 'package:health_care/model/user.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  User user = User('mac', 'email', 'pass', 'ten', 'sdt', 'nha');

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
