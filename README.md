# Caution

flutter_twitter_login library is no longer supported by the owner. If you are getting  "#import <TwitterKit/TwitterKit.h> not found error"  check out the change i made or use "tw_login: ^1.1.4". This is the same package with fix. 




# flutter_twitter_login

[![pub package](https://img.shields.io/pub/v/flutter_twitter_login.svg)](https://pub.dartlang.org/packages/flutter_twitter_login)
 [![Build Status](https://travis-ci.org/roughike/flutter_twitter_login.svg?branch=master)](https://travis-ci.org/roughike/flutter_twitter_login)
 [![Coverage Status](https://coveralls.io/repos/github/roughike/flutter_twitter_login/badge.svg)](https://coveralls.io/github/roughike/flutter_twitter_login)

A Flutter plugin for using the native TwitterKit SDKs on Android and iOS.

This plugin uses [the new Gradle 4.1 and Android Studio 3.0 project setup](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## Dart support

* Dart 1: 1.0.x.
* Dart 2: 1.1.0 and up.

## Installation

See the [installation instructions on pub](https://pub.dartlang.org/packages/flutter_twitter_login#-installing-tab-). No platform-specific configuration is needed!

## How do I use it?

Here's some sample code that should cover most of the cases. For full API reference, just [see the source code](https://github.com/roughike/flutter_twitter_login/blob/master/lib/flutter_twitter_login.dart). Everything is documented there.

```dart
var twitterLogin = new TwitterLogin(
  consumerKey: '<your consumer key>',
  consumerSecret: '<your consumer secret>',
);

final TwitterLoginResult result = await twitterLogin.authorize();

switch (result.status) {
  case TwitterLoginStatus.loggedIn:
    var session = result.session;
    _sendTokenAndSecretToServer(session.token, session.secret);
    break;
  case TwitterLoginStatus.cancelledByUser:
    _showCancelMessage();
    break;
  case TwitterLoginStatus.error:
    _showErrorMessage(result.error);
    break;
}
```
