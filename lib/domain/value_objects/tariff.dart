import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:parkomat/domain/value_objects/money.dart';
import 'package:parkomat/domain/value_objects/schedule_range.dart';

part 'tariff.freezed.dart';

/// What a garage or lot charges.
@freezed
abstract class Tariff with _$Tariff {
  const factory Tariff({
    /// Rates, each for its own time window.
    required List<TariffRate> rates,

    /// Free minutes after entering, e.g. 15 at a shopping centre.
    @Default(0) int freeMinutes,

    /// A ticket for the whole day, when there is one.
    Money? dailyTicket,
  }) = _Tariff;
}

@freezed
abstract class TariffRate with _$TariffRate {
  const factory TariffRate({
    required ScheduleRange window,
    required Money perHour,

    /// When the first hour costs more than the rest.
    Money? firstHour,
  }) = _TariffRate;
}
