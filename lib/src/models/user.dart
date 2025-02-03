import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

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
    _password = value;
    notifyListeners();
  }

   // Update user details
  void updateUser({String? newUsername, String? newEmail, String? newPassword}) async {
    if (newUsername != null) username = newUsername;
    if (newEmail != null) email = newEmail;
    if (newPassword != null) _password = await _hashPassword(newPassword);
    
    notifyListeners(); // Notify UI about changes
  }

  // Private method for hashing passwords
  Future<String> _hashPassword(String password) async {
   try{
    String salt = await FlutterBcrypt.saltWithRounds(rounds: 10);
    
    String digest = await FlutterBcrypt.hashPw(password: password, salt: salt);
    
    return digest;
   }
   on PlatformException{
    print("Failed to get Hash");
    return "Failed to get Hash";
   }
    
  }

  Future<bool> _verifyPassword(String password, String hashedPassword) async {
    try{
      return await FlutterBcrypt.verify(password: password, hash: hashedPassword);
      }
    catch (e)
    {
      print(e);
      print("Failed to verify Hash");
      return false;
    }
    
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write(email);
    sb.write(",");
    sb.write(username);
    sb.write(",");
    sb.write(password);
    return sb.toString();
    }
  }
