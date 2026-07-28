// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
  id: json['id'] as String,
  name: json['name'] as String,
  sehir: json['sehir'] as String?,
  tripTypeIds:
      (json['trip_type_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  aktif: json['aktif'] as bool? ?? true,
);

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sehir': instance.sehir,
  'trip_type_ids': instance.tripTypeIds,
  'aktif': instance.aktif,
};
