import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:parkomat/core/error/failure.dart';
import 'package:parkomat/core/error/result.dart';

/// Runs [action], returning a failure instead of throwing. Errors become
/// database failures unless [toFailure] says otherwise.
FutureResult<T> guardFuture<T>(
  Future<T> Function() action, {
  Failure Function(Object error) toFailure = _databaseFailure,
}) {
  return TaskEither.tryCatch(action, (error, _) => toFailure(error)).run();
}

/// Wraps each value of a [stream] in a result, and turns errors into
/// failures instead of stream errors.
StreamResult<T> guardStream<T>(
  Stream<T> stream, {
  Failure Function(Object error) toFailure = _databaseFailure,
}) {
  return stream.transform(
    StreamTransformer.fromHandlers(
      handleData: (value, sink) => sink.add(right(value)),
      handleError: (error, _, sink) => sink.add(left(toFailure(error))),
    ),
  );
}

Failure _databaseFailure(Object error) => Failure.database('$error');
