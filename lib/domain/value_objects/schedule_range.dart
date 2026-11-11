import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_range.freezed.dart';

/// A time window on some days of the week, e.g. Monday to Saturday,
/// 07:00–22:00.
@freezed
abstract class ScheduleRange with _$ScheduleRange {
  const factory ScheduleRange({
    /// 1 = Monday … 7 = Sunday, as in `DateTime.weekday`.
    required Set<int> weekdays,

    /// Minutes after midnight.
    required int fromMinute,

    /// Minutes after midnight, up to 1440 for "until midnight". Before
    /// [fromMinute] when the window runs past midnight into the next day.
    required int toMinute,
  }) = _ScheduleRange;

  const ScheduleRange._();

  /// Around the clock, every day.
  static const always = ScheduleRange(
    weekdays: {1, 2, 3, 4, 5, 6, 7},
    fromMinute: 0,
    toMinute: 1440,
  );

  bool get crossesMidnight => toMinute < fromMinute;
}
