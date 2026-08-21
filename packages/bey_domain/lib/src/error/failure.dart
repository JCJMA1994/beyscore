/// Base failure hierarchy for the domain layer.
///
/// Every domain operation returns Either<Failure, T>, never throws.
/// Subclass per failure category, not per function.
sealed class Failure {
  const Failure({required this.message, this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.stackTrace});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.stackTrace});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.stackTrace});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.stackTrace});
}

final class ConflictFailure extends Failure {
  const ConflictFailure({required super.message, super.stackTrace});
}

final class MatchAlreadyClosedFailure extends Failure {
  const MatchAlreadyClosedFailure()
      : super(message: 'The match is already closed.');
}

final class FinishNotAllowedFailure extends Failure {
  const FinishNotAllowedFailure()
      : super(message: 'This finish type is not allowed by current rules.');
}
