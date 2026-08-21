/// Typed exceptions for the data layer.
///
/// These are caught at the repository boundary and converted to [Failure].
/// Domain code never sees these.

class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class CacheException implements Exception {
  const CacheException({required this.message});
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException({required this.message});
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
