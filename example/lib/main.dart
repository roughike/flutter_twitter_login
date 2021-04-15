import 'package:flutter/material.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final TwitterLogin twitterLogin = TwitterLogin(
    consumerKey: 'kkOvaF1Mowy4JTvCxKTV5O1WF',
    consumerSecret: 'ZECGsI6UUDBEUVGkJe4S5vd0FGqGxC3wMJCgsXgPRfjSwRFnyH',
  );

  String _message = 'Logged out.';

  void _login() async {
    final TwitterLoginResult result = await twitterLogin.authorize();
    String newMessage = 'Login error: ${result.errorMessage}';

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
  }

  void _logout() async {
    await twitterLogin.logOut();

    setState(() {
      _message = 'Logged out.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Twitter login sample'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_message),
              MaterialButton(
                child: Text('Log in'),
                onPressed: _login,
              ),
              MaterialButton(
                child: Text('Log out'),
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
