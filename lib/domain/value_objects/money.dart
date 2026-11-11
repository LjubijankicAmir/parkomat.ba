import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';

/// An amount in convertible marks, kept in fenings (1 KM = 100 fenings) so
/// sums are exact.
@freezed
abstract class Money with _$Money {
  const factory Money(int fenings) = _Money;
}
