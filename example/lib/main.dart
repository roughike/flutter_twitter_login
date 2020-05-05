import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: 'kkOvaF1Mowy4JTvCxKTV5O1WF',
    consumerSecret: 'ZECGsI6UUDBEUVGkJe4S5vd0FGqGxC3wMJCgsXgPRfjSwRFnyH',
  );

  String _message = 'Logged out.';

  void _login() async {
    try {
      final TwitterLoginResult result = await twitterLogin.authorize();
      String newMessage;

      switch (result.status) {
        case TwitterLoginStatus.loggedIn:
          newMessage = 'Logged in! username: ${result.session.username}';
          break;
        case TwitterLoginStatus.cancelledByUser:
          newMessage = 'Login cancelled by user.';
          break;
        case TwitterLoginStatus.error:
          newMessage = 'Login error: ${result.errorMessage}';
          break;
      }
      setState(() {
        _message = newMessage;
      });
    } catch (e) {
      print(e);
    }
  }

  void _logout() async {
    await twitterLogin.logOut();

    setState(() {
      _message = 'Logged out.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Twitter login sample'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(_message),
              new RaisedButton(
                child: new Text('Log in'),
                onPressed: _login,
              ),
              new RaisedButton(
                child: new Text('Log out'),
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
