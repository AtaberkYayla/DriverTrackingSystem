// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
  id: json['id'] as String,
  plaka: json['plaka'] as String,
  aciklama: json['aciklama'] as String?,
  aktif: json['aktif'] as bool? ?? true,
);

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
  'id': instance.id,
  'plaka': instance.plaka,
  'aciklama': instance.aciklama,
  'aktif': instance.aktif,
};
