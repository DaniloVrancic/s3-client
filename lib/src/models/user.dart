import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String _username;
  String _email;
  String _password;

  // Nameless Constructor
  User()
      : _username = "guest",
        _email = "guest",
        _password = "N/A";
  // Named Constructor
  User.fromUser({
    required String username,
    String? email,
    String? password,
  })  : _username = username,
        _email = email ?? "guest",
        _password = password ?? "N/A";

  //  Getters
  String get username => _username;
  String get email => _email;
  String get password => _password;

  // Setters
  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set password(String value) {
    _password = _hashPassword(value);
    notifyListeners();
  }

   // Update user details
  void updateUser({String? newUsername, String? newEmail, String? newPassword}) {
    if (newUsername != null) username = newUsername;
    if (newEmail != null) email = newEmail;
    if (newPassword != null) _password = _hashPassword(newPassword);
    
    notifyListeners(); // Notify UI about changes
  }

  // Private method for hashing passwords
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}