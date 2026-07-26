import 'package:json_annotation/json_annotation.dart';

part 'trip_type.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TripType {
  const TripType({
    required this.id,
    required this.code,
    required this.label,
    this.requiresIrsaliye = false,
    this.sira = 0,
    this.aktif = true,
  });

  final String id;
  final String code;
  final String label;
  final bool requiresIrsaliye;
  final int sira;
  final bool aktif;

  factory TripType.fromJson(Map<String, dynamic> json) => _$TripTypeFromJson(json);

  Map<String, dynamic> toJson() => _$TripTypeToJson(this);
}
