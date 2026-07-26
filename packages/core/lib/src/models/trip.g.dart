// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
  id: json['id'] as String,
  clientTripId: json['client_trip_id'] as String,
  driverId: json['driver_id'] as String,
  vehicleId: json['vehicle_id'] as String,
  tarih: json['tarih'] as String,
  fabrikaCikisAt: json['fabrika_cikis_at'] == null
      ? null
      : DateTime.parse(json['fabrika_cikis_at'] as String),
  fabrikaGirisAt: json['fabrika_giris_at'] == null
      ? null
      : DateTime.parse(json['fabrika_giris_at'] as String),
);

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
  'id': instance.id,
  'client_trip_id': instance.clientTripId,
  'driver_id': instance.driverId,
  'vehicle_id': instance.vehicleId,
  'tarih': instance.tarih,
  'fabrika_cikis_at': instance.fabrikaCikisAt?.toIso8601String(),
  'fabrika_giris_at': instance.fabrikaGirisAt?.toIso8601String(),
};
