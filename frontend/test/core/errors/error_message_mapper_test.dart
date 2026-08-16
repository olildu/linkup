import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/errors/api_exception.dart';
import 'package:linkup/core/errors/error_message_mapper.dart';

void main() {
  group('friendlyErrorMessage', () {
    test('unwraps ApiException to its friendly message', () {
      final e = ApiException(
        statusCode: 500,
        message: 'Our servers are having a moment. Please try again shortly.',
        rawDetail: 'boom',
      );
      expect(
        friendlyErrorMessage(e),
        'Our servers are having a moment. Please try again shortly.',
      );
    });

    test('unwraps SwipeLimitException to its message', () {
      final e = SwipeLimitException(
        "You've hit your daily like limit. Try again tomorrow.",
      );
      expect(
        friendlyErrorMessage(e),
        "You've hit your daily like limit. Try again tomorrow.",
      );
    });

    test('maps a raw duplicate-email exception string to a friendly message', () {
      final e = Exception(
        'Signup failed: duplicate key value violates unique constraint "users_email_key"',
      );
      expect(
        friendlyErrorMessage(e),
        'This email is already registered. Please log in.',
      );
    });

    test('maps SocketException to a network message', () {
      expect(
        friendlyErrorMessage(const SocketException('Failed host lookup')),
        'No internet connection. Please check your network.',
      );
    });

    test(
      'maps a raw database/stacktrace-looking string to the generic fallback',
      () {
        final e = Exception(
          'psycopg2.errors.UndefinedTable: relation "foo" does not exist\nTraceback (most recent call last):',
        );
        expect(
          friendlyErrorMessage(e),
          'Something went wrong. Please try again.',
        );
      },
    );

    test('passes through a short, already-human message unchanged', () {
      expect(
        friendlyErrorMessage(Exception('Failed to send OTP')),
        'Failed to send OTP',
      );
    });

    test('returns the generic fallback for null', () {
      expect(
        friendlyErrorMessage(null),
        'Something went wrong. Please try again.',
      );
    });
  });

  group('friendlyFromResponse', () {
    test(
      'maps a raw 500 database detail to the generic server message, never the raw text',
      () {
        final message = friendlyFromResponse(
          500,
          'Database error: relation "users" does not exist',
        );
        expect(
          message,
          'Our servers are having a moment. Please try again shortly.',
        );
        expect(message.contains('relation'), isFalse);
      },
    );

    test('maps 429 to a rate-limit message', () {
      expect(
        friendlyFromResponse(429, 'Daily like limit reached. Try again later.'),
        "You've used all your likes for today. Come back tomorrow for more matches!",
      );
    });

    test('maps 401 to a session-expired message', () {
      expect(
        friendlyFromResponse(401, 'Invalid or expired token'),
        'Your session has expired. Please log in again.',
      );
    });

    test('detail substring match wins over generic status mapping', () {
      expect(
        friendlyFromResponse(
          500,
          'duplicate key value violates unique constraint users_email_key',
        ),
        'This email is already registered. Please log in.',
      );
    });
  });

  group('sanitizeDisplayMessage', () {
    test('leaves an intentional friendly literal untouched', () {
      expect(
        sanitizeDisplayMessage('User blocked successfully'),
        'User blocked successfully',
      );
    });

    test('strips a leading Exception: prefix', () {
      expect(
        sanitizeDisplayMessage('Exception: Failed to send OTP'),
        'Failed to send OTP',
      );
    });

    test('replaces raw-looking text with the generic fallback', () {
      expect(
        sanitizeDisplayMessage('psycopg2.OperationalError: connection refused'),
        'Something went wrong. Please try again.',
      );
    });
  });
}
