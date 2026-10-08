/// Audius API and Data Layer Exception Definitions
abstract class AudiusException implements Exception {
  final String message;
  final int? statusCode;

  const AudiusException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when there is no internet connection or socket error occurs
class NetworkException extends AudiusException {
  const NetworkException([
    super.message =
        'Network connection failed. Please check your internet connection.',
  ]);
}

/// Thrown when a request times out
class TimeoutException extends AudiusException {
  const TimeoutException([
    super.message =
        'Request timed out. The Audius server took too long to respond.',
  ]);
}

/// Thrown when all discovery node hosts are unreachable
class HostUnavailableException extends AudiusException {
  const HostUnavailableException([
    super.message = 'All Audius discovery nodes are currently unreachable.',
  ]);
}

/// Thrown when an item is not found (404)
class NotFoundException extends AudiusException {
  const NotFoundException([
    super.message = 'Requested music resource was not found.',
  ]) : super(statusCode: 404);
}

/// Thrown when Audius rate limit is exceeded (429)
class RateLimitException extends AudiusException {
  const RateLimitException([
    super.message = 'Audius rate limit reached. Please try again shortly.',
  ]) : super(statusCode: 429);
}

/// Thrown when the server returns an unexpected status code or malformed JSON
class InvalidResponseException extends AudiusException {
  const InvalidResponseException([
    super.message = 'Invalid response received from Audius node.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}
