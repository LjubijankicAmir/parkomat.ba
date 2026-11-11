import 'package:freezed_annotation/freezed_annotation.dart';

part 'provenance.freezed.dart';

/// Where data came from and when a person last checked it.
@freezed
abstract class Provenance with _$Provenance {
  const factory Provenance({
    required List<Uri> sources,

    /// `null` until someone has checked it on the street.
    DateTime? verifiedAt,
  }) = _Provenance;
}
