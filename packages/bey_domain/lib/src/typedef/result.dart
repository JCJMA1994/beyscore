import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

/// Synchronous result: a value or a failure.
typedef Result<T> = Either<Failure, T>;

/// Asynchronous result.
typedef AsyncResult<T> = Future<Either<Failure, T>>;

/// Stream of results (for reactive reads via Drift).
typedef ResultStream<T> = Stream<Either<Failure, T>>;
