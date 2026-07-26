// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Manager _$ManagerFromJson(Map<String, dynamic> json) => Manager(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  aktif: json['aktif'] as bool? ?? true,
);

Map<String, dynamic> _$ManagerToJson(Manager instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'aktif': instance.aktif,
};
