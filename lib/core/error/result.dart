import 'package:fpdart/fpdart.dart';
import 'package:parkomat/core/error/failure.dart';

typedef Result<T> = Either<Failure, T>;
typedef FutureResult<T> = Future<Result<T>>;
typedef StreamResult<T> = Stream<Result<T>>;
