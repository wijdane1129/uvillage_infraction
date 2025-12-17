import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _fullName = "";
  String _email = "";
  String _language = "en";
  String _password = "";
  String get fullName => _fullName;
  String get email => _email;
  String get language => _language;
  String get password => _password;
  void setFullName(String fullName) {
    _fullName = fullName;
    notifyListeners();
  }
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }
  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }
  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }
}
