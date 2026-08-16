/// Thrown by [CustomHttpClient] for any non-2xx HTTP response.
///
/// [message] is always safe to show to the user directly — it has already
/// been passed through the error mapper. [rawDetail] retains the original
/// backend `detail` (or transport error) for logging.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String rawDetail;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.rawDetail,
  });

  @override
  String toString() => message;
}

/// Thrown when the backend responds 429 to a swipe action.
/// Kept as a distinct type so callers can special-case the "out of swipes"
/// flow (e.g. [MatchesBloc]) without string-matching a generic exception.
class SwipeLimitException implements Exception {
  final String message;
  SwipeLimitException(this.message);

  @override
  String toString() => message;
}

/// Thrown when login fails because no account exists for the given email.
/// Kept as a distinct type so [AuthBloc] can special-case the "no account"
/// flow without string-matching a generic exception.
class AccountNotFoundException implements Exception {
  final String message;
  AccountNotFoundException(this.message);

  @override
  String toString() => message;
}
