import 'package:freezed_annotation/freezed_annotation.dart';

part 'height_limit.freezed.dart';

/// The tallest vehicle that fits through an entrance.
@freezed
abstract class HeightLimit with _$HeightLimit {
  const factory HeightLimit({required int centimetres}) = _HeightLimit;
}
