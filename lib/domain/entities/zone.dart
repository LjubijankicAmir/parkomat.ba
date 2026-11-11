import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:parkomat/domain/entities/zone_stretch.dart';
import 'package:parkomat/domain/value_objects/money.dart';
import 'package:parkomat/domain/value_objects/provenance.dart';
import 'package:parkomat/domain/value_objects/schedule_range.dart';

part 'zone.freezed.dart';

/// A paid street-parking zone, paid with one SMS per hour.
@freezed
abstract class Zone with _$Zone {
  const factory Zone({
    required String id,

    /// The number on the street signs and the badge, e.g. 1.
    required int number,
    required String name,

    /// The short number the SMS goes to, e.g. "0832001".
    required String smsNumber,
    required Money pricePerHour,

    /// When parking is charged. Outside these hours, and on the city's
    /// holidays, it's free.
    required List<ScheduleRange> paidHours,
    required List<ZoneStretch> stretches,
    required Provenance provenance,
    Money? dailyTicket,

    /// The longest stay allowed, when there's a limit.
    Duration? maxStay,
  }) = _Zone;
}
