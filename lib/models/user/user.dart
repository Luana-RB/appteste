import 'package:flutter/material.dart';

class User {
  final String name;
  final String email;
  final String password;
  final String groupName;

  User(
      {required this.name,
      required this.email,
      required this.password,
      required this.groupName});
}
