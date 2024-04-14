import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import './loginPage.dart';
import './components/redirectButton.dart' as component;

class UserChosenPage extends StatefulWidget {
  static const String route = '/users';
  final String url;
  final String service;

  const UserChosenPage(this.url, this.service, {Key? key}) : super(key: key);

  @override
  _UserChosenPageState createState() => _UserChosenPageState(url, service);
}

class _UserChosenPageState extends State<UserChosenPage> {
  final String url;
  final String service;
  final GlobalKey scaffoldKey = GlobalKey();

  _UserChosenPageState(this.url, this.service);

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
      }
    });
  }
  
  Widget UserList(Map<String, String> users) {
    return ListView.builder(
      itemCount: users.length + 1,
      itemBuilder: (context, index) {
        if (index < users.length) {
          return ListTile(
            title: Text(
              users.keys.elementAt(index),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              existingUserLogin(service, users.values.elementAt(index));
            },
          );
        } else {
          return component.RedirectButton('New User Login', "${LoginPage.route}?service=${service}");
        }
      },
    );
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
        child: UserList(userToken),
      )
    );
  }
}