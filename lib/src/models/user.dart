import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class User with ChangeNotifier {
  String _username;
  String _email;
  String? _password;

  // Nameless Constructor
  User()
      : _username = "---guest",
        _email = "---guest",
        _password = null;
  // Named Constructor
  User.fromInfo({
    required String username,
    required String email,
    String? password,
  })  : _username = username,
        _email = email,
        _password = password ?? "N/A";

  //  Getters
  String get username => _username;
  String get email => _email;
  String get password => _password ?? "[N/A]";

  // Setters
  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set password(String? value) {
    _password = value;
    notifyListeners();
  }

  bool isLoggedIn(){
    
    if(_username.isNotEmpty && _email.isNotEmpty && _password != null)
    {
      if(!_username.contains('---') && !_email.contains('---'))
      {
        return true;
      }
    }
    return false;
  }
   // Update user details
  void setUser({String? newUsername, String? newEmail, String? newPassword}) {
    if (newUsername != null) username = newUsername;
    if (newEmail != null) email = newEmail;
    if (newPassword != null) password = newPassword;
    
    notifyListeners(); // Notify UI about changes
  }

  logout() {
    _username = "---guest";
    _email = "---guest";
    _password = null;
    notifyListeners();
  }

  // Private method for hashing passwords
  static Future<String> hashPassword(String password) async {
   try{
    String salt = BCrypt.gensalt(logRounds: 10);
    
    String digest = BCrypt.hashpw(password, salt);
    
    return digest;
   }
   on PlatformException{
    return "Failed to get Hash";
   }
    
  }

  bool verifyPassword(String password, String hashedPassword) {
    try{
      return BCrypt.checkpw(password, hashedPassword);
      }
    catch (e)
    {
      print(e);
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
