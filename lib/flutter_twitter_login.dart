import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A Flutter plugin for authenticating users by using the native Twitter
/// login SDKs on Android & iOS.
class TwitterLogin {
  static const MethodChannel channel =
      const MethodChannel('com.roughike/flutter_twitter_login');

  /// Creates a new Twitter login instance, with the specified key and secret.
  ///
  /// The [consumerKey] and [consumerSecret] can be obtained from the Twitter
  /// apps site at https://apps.twitter.com/, in the "Keys and Access Tokens"
  /// tab.
  TwitterLogin({
    @required this.consumerKey,
    @required this.consumerSecret,
  })  : assert(consumerKey != null && consumerKey.isNotEmpty,
            'Consumer key may not be null or empty.'),
        assert(consumerSecret != null && consumerSecret.isNotEmpty,
            'Consumer secret may not be null or empty.'),
        _keys = {
          'consumerKey': consumerKey,
          'consumerSecret': consumerSecret,
        };

  final String consumerKey;
  final String consumerSecret;
  final Map<String, String> _keys;

  /// Returns whether the user is currently logged in or not.
  ///
  /// Convenience method for checking if the [currentSession] is not null.
  Future<bool> get isSessionActive async => await currentSession != null;

  /// Retrieves the currently active session, if any.
  ///
  /// A common use case for this is logging the user automatically in if they
  /// have already logged in before and the session is still active.
  ///
  /// For example:
  ///
  /// ```dart
  /// final TwitterSession session = await twitterLogin.currentSession;
  ///
  /// if (session != null) {
  ///   _fetchTweets(session);
  /// } else {
  ///   _showLoginRequiredUI();
  /// }
  /// ```
  ///
  /// If the user is not logged in, this returns null.
  Future<TwitterSession> get currentSession async {
    final Map<dynamic, dynamic> session =
        await channel.invokeMethod('getCurrentSession', _keys);

    if (session == null) {
      return null;
    }

    return new TwitterSession.fromMap(session.cast<String, dynamic>());
  }

  /// Logs the user in.
  ///
  /// If the user has a native Twitter client installed, this will present a
  /// native login screen. Otherwise a WebView is used.
  ///
  /// The "Callback URL" field must be configured to a valid address in your
  /// app's "Settings" tab. When using the Twitter login only on mobile devices,
  /// an example of a valid callback url would be http://127.0.0.1:4000.
  ///
  /// Use [TwitterLoginResult.status] for determining if the login was successful
  /// or not. For example:
  ///
  /// ```dart
  /// var twitterLogin = new TwitterLogin(
  ///   consumerKey: '<your consumer key>',
  ///   consumerSecret: '<your consumer secret>',
  /// );
  ///
  /// final TwitterLoginResult result = await twitterLogin.authorize();
  ///
  /// switch (result.status) {
  ///   case TwitterLoginStatus.loggedIn:
  ///     var session = result.session;
  ///     _sendTokenAndSecretToServer(session.token, session.secret);
  ///     break;
  ///   case TwitterLoginStatus.cancelledByUser:
  ///     _showCancelMessage();
  ///     break;
  ///   case TwitterLoginStatus.error:
  ///     _showErrorMessage(result.error);
  ///     break;
  /// }
  /// ```
  ///
  /// See the [TwitterLoginResult] class for more documentation.
  Future<TwitterLoginResult> authorize() async {
    final Map<dynamic, dynamic> result =
        await channel.invokeMethod('authorize', _keys);
    return new TwitterLoginResult._(result.cast<String, dynamic>());
  }

  /// Logs the currently logged in user out.
  Future<void> logOut() async => channel.invokeMethod('logOut', _keys);
}

/// The result when a Twitter login flow has completed.
///
/// To handle this result, first check what the [status] is. If the status
/// equals [TwitterLoginStatus.loggedIn], the login was successful. In this
/// case, the [session] contains all relevant information about the
/// currently logged in user.
class TwitterLoginResult {
  /// The status after a Twitter login flow has completed.
  ///
  /// This affects whether the [session] or [error] are available or not.
  /// If the user cancelled the login flow, both [session] and [errorMessage]
  /// are null.
  final TwitterLoginStatus status;

  /// Only available when the [status] equals [TwitterLoginStatus.loggedIn],
  /// otherwise null.
  final TwitterSession session;

  /// Only available when the [status] equals [TwitterLoginStatus.error]
  /// otherwise null.
  final String errorMessage;

  TwitterLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status'], map['errorMessage']),
        session = map['session'] != null
            ? new TwitterSession.fromMap(
                map['session'].cast<String, dynamic>(),
              )
            : null,
        errorMessage = map['errorMessage'];

  static TwitterLoginStatus _parseStatus(String status, String errorMessage) {
    switch (status) {
      case 'loggedIn':
        return TwitterLoginStatus.loggedIn;
      case 'error':
        // Kind of a hack, but the only way of determining this.
        if (errorMessage.contains('canceled') ||
            errorMessage.contains('cancelled')) {
          return TwitterLoginStatus.cancelledByUser;
        }

        return TwitterLoginStatus.error;
    }

    throw new StateError('Invalid status: $status');
  }
}

/// The status after a Twitter login flow has completed.
enum TwitterLoginStatus {
  /// The login was successful and the user is now logged in.
  loggedIn,

  /// The user cancelled the login flow, usually by backing out of the dialog.
  ///
  /// This might be unrealiable; see the [_parseStatus] method in TwitterLoginResult.
  cancelledByUser,

  /// The login flow completed, but for some reason resulted in an error. The
  /// user couldn't log in.
  error,
}

/// The information about a Twitter user session.
///
/// Includes the token and secret, along with the user's id and name. Both
/// the [token] and [secret] are needed for making authenticated Twitter API
/// calls.
class TwitterSession {
  final String secret;
  final String token;

  /// The user's unique identifier, usually a long series of numbers.
  final String userId;

  /// The user's Twitter handle.
  ///
  /// For example, if you can visit your Twitter profile by typing the URL
  /// http://twitter.com/hello, your Twitter handle (or username) is "hello".
  final String username;

  /// Constructs a new access token instance from a [Map].
  ///
  /// This is used mostly internally by this library.
  TwitterSession.fromMap(Map<String, dynamic> map)
      : secret = map['secret'],
        token = map['token'],
        userId = map['userId'],
        username = map['username'];

  /// Transforms this access token to a [Map].
  ///
  /// This could be useful for encoding this access token as JSON and then
  /// sending it to a server.
  Map<String, dynamic> toMap() {
    return {
      'secret': secret,
      'token': token,
      'userId': userId,
      'username': username,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TwitterSession &&
          runtimeType == other.runtimeType &&
          secret == other.secret &&
          token == other.token &&
          userId == other.userId &&
          username == other.username;

  @override
  int get hashCode =>
      secret.hashCode ^ token.hashCode ^ userId.hashCode ^ username.hashCode;
}
