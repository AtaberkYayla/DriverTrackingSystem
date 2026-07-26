// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requester.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Requester _$RequesterFromJson(Map<String, dynamic> json) => Requester(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  aktif: json['aktif'] as bool? ?? true,
);

Map<String, dynamic> _$RequesterToJson(Requester instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'aktif': instance.aktif,
};
