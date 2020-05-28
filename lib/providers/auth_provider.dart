import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _userDataKey = 'userData';
  String _token;
  DateTime _expireDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expireDate != null &&
        _expireDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signin(String email, String password) async {
    try {
      final response = await AuthService.signin(email, password);
      final responseBody = json.decode(response.body);
      _token = responseBody['idToken'];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      _userId = responseBody['localId'];
      _autoSignout();
      notifyListeners();
      _saveUserData();
    } catch (error) {
      throw error;
    }
  }

  Future<void> _saveUserData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expireDate': _expireDate.toIso8601String(),
    });
    sharedPreferences.setString(_userDataKey, userData);
  }

  Future<bool> tryAutoLogin() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey(_userDataKey)) {
      return false;
    }

    final userData = json.decode(sharedPreferences.getString(_userDataKey))
        as Map<String, Object>;
    final expireDate = DateTime.parse(userData['expireDate']);
    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = userData['token'];
    _userId = userData['userId'];
    _expireDate = expireDate;
    notifyListeners();
    _autoSignout();
    return true;
  }

  Future<void> signup(String email, String password) async {
    await AuthService.signup(email, password);
  }

  void signout() {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    _clearUserData();
    notifyListeners();
  }

  Future<void> _clearUserData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(_userDataKey);
  }

  void _autoSignout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpire = _expireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), signout);
  }
}
