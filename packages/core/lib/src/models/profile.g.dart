// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  role: $enumDecode(_$AppRoleEnumMap, json['role']),
  phone: json['phone'] as String?,
  aktif: json['aktif'] as bool? ?? true,
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'role': instance.role,
  'phone': instance.phone,
  'aktif': instance.aktif,
};

const _$AppRoleEnumMap = {
  AppRole.driver: 'driver',
  AppRole.office: 'office',
  AppRole.admin: 'admin',
};
