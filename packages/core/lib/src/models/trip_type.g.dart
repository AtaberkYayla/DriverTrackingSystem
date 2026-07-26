// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripType _$TripTypeFromJson(Map<String, dynamic> json) => TripType(
  id: json['id'] as String,
  code: json['code'] as String,
  label: json['label'] as String,
  requiresIrsaliye: json['requires_irsaliye'] as bool? ?? false,
  sira: (json['sira'] as num?)?.toInt() ?? 0,
  aktif: json['aktif'] as bool? ?? true,
);

Map<String, dynamic> _$TripTypeToJson(TripType instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'label': instance.label,
  'requires_irsaliye': instance.requiresIrsaliye,
  'sira': instance.sira,
  'aktif': instance.aktif,
};
