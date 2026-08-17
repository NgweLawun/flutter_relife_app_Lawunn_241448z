


import 'package:flutter/material.dart';


class UserData extends ChangeNotifier {
  String _email = '';
  String _username = '';
  String _phoneNumber = '';
  String _password = '';


  String get email => _email;
  String get username => _username;
  String get phoneNumber => _phoneNumber;
  String get password => _password;

  String _photoUrl = '';
    String get photoUrl => _photoUrl;
    set photoUrl(String value) {
      _photoUrl = value;
      notifyListeners();
    }

  void setCredentials(String email, String password, String username, String phoneNumber) {
    _email = email;
    _password = password;
    _username = username;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set phoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }
  
  // void updateProfile({String? email, String? username, String? phoneNumber}) {
  //   if (email != null) _email = email;
  //   if (username != null) _username = username;
  //   if (phoneNumber != null) _phoneNumber = phoneNumber;
  //   notifyListeners();
  // }
}