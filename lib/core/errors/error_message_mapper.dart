import 'dart:async';
import 'dart:io';

import 'package:linkup/core/errors/api_exception.dart';

/// Centralized error-to-user-message mapping.
///
/// Nothing outside this file should decide what error text a user sees.
/// Any new backend error string should be added to [_detailRules] here,
/// not handled ad hoc at a call site.
const String _fallbackMessage = 'Something went wrong. Please try again.';

/// Backend `detail` substring -> friendly message. Order matters: first
/// match wins, so put more specific substrings above their broader cousins.
const List<MapEntry<String, String>> _detailRules = [
  MapEntry('users_email_key', 'This email is already registered. Please log in.'),
  MapEntry('duplicate key', 'This email is already registered. Please log in.'),
  MapEntry('Invalid username or password', 'Incorrect email or password.'),
  MapEntry('Invalid email or password', 'Incorrect email or password.'),
  MapEntry('OTP verification failed', 'The code you entered is incorrect. Please try again.'),
  MapEntry('Invalid OTP', 'The code you entered is incorrect. Please try again.'),
  MapEntry('OTP expired', 'That code has expired. Please request a new one.'),
  MapEntry('expired or not found', 'That code has expired. Please request a new one.'),
  MapEntry(
    'Password must contain',
    'Password needs an uppercase letter, a lowercase letter, and a symbol.',
  ),
  MapEntry('multiple faces', 'Please upload a photo with just your face.'),
  MapEntry('Face not detected', "We couldn't detect a clear face in your photo."),
  MapEntry('No face detected', "We couldn't detect a clear face in your photo."),
  MapEntry('Converted file too large', 'That file is too large. Please choose a smaller one.'),
  MapEntry('File too large', 'That file is too large. Please choose a smaller one.'),
  MapEntry('Invalid image file', "That image couldn't be processed. Please try another."),
  MapEntry('Unable to fetch image from URL', "We couldn't load that image. Please try again."),
  MapEntry('Match does not exist', 'This match is no longer available.'),
  MapEntry('not a participant', "You don't have access to this chat."),
  MapEntry('User not in match queue', "You're not in the matching queue right now."),
  MapEntry('Daily like limit reached', "You've used all your likes for today. Come back tomorrow for more matches!"),
  MapEntry('User not found', "We couldn't find that user."),
  MapEntry('No fields to update', "There's nothing to update."),
  MapEntry('Invalid or expired token', 'Your session has expired. Please log in again.'),
  MapEntry('Invalid refresh token', 'Your session has expired. Please log in again.'),
  MapEntry('token expired', 'Your session has expired. Please log in again.'),
  MapEntry('Token expired', 'Your session has expired. Please log in again.'),
  MapEntry('Invalid token', 'Your session has expired. Please log in again.'),
];

const List<String> _rawTextMarkers = [
  'exception:',
  'error:',
  'psycopg2',
  'duplicate key',
  'traceback',
  'stack trace',
  '#0 ',
  "null check operator",
  "type '",
  'sqlstate',
  'errno',
];

bool _looksRaw(String message) {
  final lower = message.toLowerCase();
  return _rawTextMarkers.any(lower.contains);
}

String _stripKnownPrefixes(String message) {
  var cleaned = message.trim();
  const prefixes = ['ApiException: ', 'Exception: ', 'FormatException: ', 'HttpException: ', 'Error: '];
  for (final prefix in prefixes) {
    if (cleaned.startsWith(prefix)) {
      cleaned = cleaned.substring(prefix.length).trim();
    }
  }
  return cleaned;
}

/// Maps arbitrary caught-error text (already stringified) to a friendly
/// message: strips known prefixes, applies the detail rules, and falls
/// back to a generic message if what's left still looks like raw internals.
String _mapRawText(String raw) {
  final cleaned = _stripKnownPrefixes(raw);
  for (final rule in _detailRules) {
    if (cleaned.contains(rule.key)) return rule.value;
  }
  if (cleaned.isEmpty || _looksRaw(cleaned) || cleaned.length > 160) {
    return _fallbackMessage;
  }
  return cleaned;
}

/// Maps a backend HTTP response (status code + `detail` field) to a
/// friendly message. Used by [CustomHttpClient] and the auth datasource,
/// which talk to the backend directly and have both pieces of information.
String friendlyFromResponse(int statusCode, String detail) {
  for (final rule in _detailRules) {
    if (detail.contains(rule.key)) return rule.value;
  }

  switch (statusCode) {
    case 400:
      return "We couldn't process that request. Please check your details and try again.";
    case 401:
      return 'Your session has expired. Please log in again.';
    case 403:
      return "You don't have permission to do that.";
    case 404:
      return "We couldn't find what you're looking for.";
    case 413:
      return 'That file is too large. Please choose a smaller one.';
    case 422:
      return "Some details couldn't be processed. Please try again.";
    case 429:
      return "You're doing that a bit too often. Please slow down and try again shortly.";
  }
  if (statusCode >= 500) {
    return 'Our servers are having a moment. Please try again shortly.';
  }
  return detail.isEmpty ? _fallbackMessage : _mapRawText(detail);
}

/// Maps any caught error (from a `catch (e)` block in a bloc, use case, or
/// widget) to a friendly message. This is the function blocs should call
/// instead of `e.toString()`.
String friendlyErrorMessage(Object? error) {
  if (error == null) return _fallbackMessage;

  if (error is ApiException) return error.message;
  if (error is SwipeLimitException) return error.message;
  if (error is SocketException) {
    return 'No internet connection. Please check your network.';
  }
  if (error is TimeoutException) {
    return "That's taking longer than usual. Please try again.";
  }
  if (error is FormatException) {
    return 'Unexpected response from the server. Please try again.';
  }

  return _mapRawText(error.toString());
}

/// Last-line-of-defense for display widgets (`showToast`,
/// `showScaffoldMessage`). Unlike [friendlyErrorMessage], the input here may
/// already be an intentional, friendly, hardcoded UI string (e.g. "User
/// blocked successfully") — so this only strips an obvious exception
/// prefix and replaces the text if it still looks like raw internals. It
/// never re-maps one friendly phrase to another.
String sanitizeDisplayMessage(String message) {
  final cleaned = _stripKnownPrefixes(message);
  if (cleaned.isEmpty || _looksRaw(cleaned)) {
    return _fallbackMessage;
  }
  return cleaned;
}
