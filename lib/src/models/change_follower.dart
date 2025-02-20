import 'package:flutter/material.dart';

class ChangeFollower extends ChangeNotifier {
  bool _needToGetObjects = false;

  bool get needToGetObjects => _needToGetObjects;

  set needToGetObjects(bool value) {
    _needToGetObjects = value;

    if(value == true)
    {
      notifyListeners();
    }
  }
}