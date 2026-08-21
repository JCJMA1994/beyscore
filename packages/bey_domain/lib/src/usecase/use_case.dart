import '../typedef/result.dart';

/// Contract for a use case that returns a single result.
///
/// Only battle and tournament features use these. If the use case
/// would just forward to the repo, skip it (CLAUDE.md section 5).
abstract class UseCase<Out, In> {
  const UseCase();
  AsyncResult<Out> call(In params);
}

/// Contract for a use case that returns a stream of results.
///
/// Drift watches return streams natively; this wraps them with
/// failure handling at the boundary.
abstract class StreamUseCase<Out, In> {
  const StreamUseCase();
  ResultStream<Out> call(In params);
}

/// Marker for use cases that take no parameters.
class NoParams {
  const NoParams();
}
