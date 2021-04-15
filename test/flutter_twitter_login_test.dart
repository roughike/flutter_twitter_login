import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$TwitterLogin', () {
    const MethodChannel channel = const MethodChannel(
      'com.roughike/flutter_twitter_login',
    );

    const kSessionMap = const {
      'username': 'test_user_name',
      'userId': 'abc123',
      'token': 'test_access_token',
      'secret': 'test_secret',
    };

    const kLoggedInResponse = const {
      'status': 'loggedIn',
      'session': kSessionMap,
    };

    const kTokenAndSecretArguments = const {
      'consumerKey': 'consumer_key',
      'consumerSecret': 'consumer_secret',
    };

    const kErrorResponse = const {
      'status': 'error',
      'errorMessage': 'test error message',
    };

    final List<MethodCall> log = [];
    late TwitterLogin sut;

    void setMethodCallResponse(Map<String, dynamic>? response) {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return new Future.value(response);
      });
    }

    void expectSessionParsedCorrectly(TwitterSession session) {
      expect(session.username, 'test_user_name');
      expect(session.userId, 'abc123');
      expect(session.token, 'test_access_token');
      expect(session.secret, 'test_secret');
    }

    setUp(() {
      sut = new TwitterLogin(
        consumerKey: 'consumer_key',
        consumerSecret: 'consumer_secret',
      );

      log.clear();
    });

    test('can not call constructor with null or empty key or secret', () {
      expect(() => new TwitterLogin(consumerKey: null, consumerSecret: null),
          throwsA(anything));
      expect(() => new TwitterLogin(consumerKey: '', consumerSecret: ''),
          throwsA(anything));
    });

    test('get isSessionActive - false when currentSession is null', () async {
      setMethodCallResponse(null);

      final bool isSessionActive = await sut.isSessionActive;
      expect(isSessionActive, isFalse);
      expect(log, [
        isMethodCall(
          'getCurrentSession',
          arguments: kTokenAndSecretArguments,
        ),
      ]);
    });

    test('get isSessionActive - true when currentSession is not null',
        () async {
      setMethodCallResponse(kSessionMap);

      final bool isSessionActive = await sut.isSessionActive;
      expect(isSessionActive, isTrue);
      expect(log, [
        isMethodCall(
          'getCurrentSession',
          arguments: kTokenAndSecretArguments,
        ),
      ]);
    });

    test('get currentSession - handles null response gracefully', () async {
      setMethodCallResponse(null);

      final TwitterSession? session = await sut.currentSession;
      expect(session, isNull);
      expect(log, [
        isMethodCall(
          'getCurrentSession',
          arguments: kTokenAndSecretArguments,
        ),
      ]);
    });

    test('get currentSession - parses session correctly', () async {
      setMethodCallResponse(kSessionMap);

      final TwitterSession session = await (sut.currentSession as FutureOr<TwitterSession>);
      expectSessionParsedCorrectly(session);
      expect(log, [
        isMethodCall(
          'getCurrentSession',
          arguments: kTokenAndSecretArguments,
        ),
      ]);
    });

    test('authorize - calls the right method', () async {
      setMethodCallResponse(kLoggedInResponse);

      await sut.authorize();

      expect(log, [
        isMethodCall(
          'authorize',
          arguments: kTokenAndSecretArguments,
        ),
      ]);
    });

    test('authorize - user logged in', () async {
      setMethodCallResponse(kLoggedInResponse);

      final TwitterLoginResult result = await sut.authorize();

      expect(result.status, TwitterLoginStatus.loggedIn);
      expectSessionParsedCorrectly(result.session!);
    });

    test('authorize - cancelled by user', () async {
      setMethodCallResponse({
        'status': 'error',
        'errorMessage': 'Authorization failed, request was canceled.',
      });

      final TwitterLoginResult androidResult = await sut.authorize();
      expect(androidResult.status, TwitterLoginStatus.cancelledByUser);

      setMethodCallResponse({
        'status': 'error',
        'errorMessage': 'User cancelled authentication.',
      });

      final TwitterLoginResult iosResult = await sut.authorize();
      expect(iosResult.status, TwitterLoginStatus.cancelledByUser);
    });

    test('authorize - error', () async {
      setMethodCallResponse(kErrorResponse);

      final TwitterLoginResult result = await sut.authorize();
      expect(result.status, TwitterLoginStatus.error);
    });

    test('logout', () async {
      setMethodCallResponse(null);

      await sut.logOut();

      expect(log, [
        isMethodCall(
          'logOut',
          arguments: kTokenAndSecretArguments,
        )
      ]);
    });

    test('access token equality test', () {
      final TwitterSession first = new TwitterSession.fromMap(kSessionMap);
      final TwitterSession second = new TwitterSession.fromMap(kSessionMap);

      expect(first, equals(second));
    });

    test('access token from and to Map', () async {
      final TwitterSession session = new TwitterSession.fromMap(kSessionMap);

      expectSessionParsedCorrectly(session);
      expect(
        session.toMap(),
        {
          'username': 'test_user_name',
          'userId': 'abc123',
          'token': 'test_access_token',
          'secret': 'test_secret',
        },
      );
    });
  });
}
