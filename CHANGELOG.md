## 1.1.0

* Dart 2 support! There should not be any breaking changes. Please do file issues if you have problems.

## 1.0.1

* Fixed `onActivityResult` override that was potentially preventing other plugins from receiving `Activity` results.
* Fixed a logout crash on Android in the case when the user wasn't already logged in.
* Fixed #1 by returning NSNull from the `sessionToMap` method when the twitter session is nil.
* Fix #2 by clarifying the documentation. Also explain the `toMap` and `fromMap` methods of `TwitterSession` more clearly.

## 1.0.0

* Initial release.