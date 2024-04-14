import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class LoginPage extends StatefulWidget {
  static const String route = '/login';
  final String url;
  final String service;

  const LoginPage(this.url, this.service, {Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState(url, service);
}

class _LoginPageState extends State<LoginPage> {
  final String url;
  final String service;
  final GlobalKey scaffoldKey = GlobalKey();
  final usernameText = TextEditingController();
  final passwordText = TextEditingController();

  _LoginPageState(this.url, this.service);

  Future<String> newUserLogin(String username, password) async {
    String apiUrl = '$url/login';
    return http.post (
      Uri.parse(apiUrl),
      body: <String, dynamic> {
        'username': username,
        'password': password,
      }
    )
    .then( (response) async {
      final html.Storage localStorage = html.window.localStorage;
      String token = "";
      if (response.statusCode == 200) {
        token = jsonDecode(response.body)["token"];
        localStorage['UserToken-${username}'] = token;
      } else {
        // return the error message
        html.window.alert("Error happen in login");
      }
      usernameText.text = "";
      passwordText.text = "";
      return token;
    });
  }

  existingUserLogin(String service, token) {
    String apiUrl = '$url/service/login';
    http.post(
      Uri.parse(apiUrl),
      body: { "service": service },
      headers: { "Authorization": token }
    ).then( (response) {
      if (response.statusCode == 200) {
        Map body = jsonDecode(response.body);
        String url = body['url']!;
        String userLoginToken = body['token']!;
        html.window.location.replace("${url}?token=${userLoginToken}");
      } else if (response.statusCode == 302) {
        String? redirectUrl = response.headers['Location'];
        if (redirectUrl != null) {
          html.window.location.replace(redirectUrl);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final html.Storage localStorage = html.window.localStorage;
    Map<String, String> userToken = Map();
    for (String key in localStorage.keys.where((element) => element.contains('UserToken-'))) {
      String username = key.replaceFirst('UserToken-', '');
      userToken[username] = localStorage[key]!;
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      key: this.scaffoldKey,
      body: Center(
        child: Column(
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
              controller: usernameText,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              controller: passwordText,
            ),
            TextButton(
              onPressed: () async {
                String token = await newUserLogin(usernameText.text, passwordText.text);
                existingUserLogin(service, token);
              },
              child: const Text("Login")
            )
          ],
        )
      )
    );
  }
}