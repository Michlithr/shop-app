import 'dart:convert';

import 'package:http/http.dart';

import '../models/http_exception.dart';

class AuthService {
  static Future<Response> signin(String email, String password) async {
    const urlSegment = "signInWithPassword";
    try {
      return authenticate(email, password, urlSegment);
    } catch (error) {
      throw (error);
    }
  }

  static Future<Response> signup(String email, String password) async {
    const urlSegment = "signUp";
    try {
      return authenticate(email, password, urlSegment);
    } catch (error) {
      throw (error);
    }
  }

  static Future<Response> authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=[API_KEY]";
    final body = json.encode(
      {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
    final response = await post(url, body: body);
    final responseBody = json.decode(response.body);
    if (responseBody['error'] != null) {
      throw HttpException(responseBody['error']['message']);
    }
    return response;
  }
}
