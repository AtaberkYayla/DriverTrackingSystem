// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_stop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripStop _$TripStopFromJson(Map<String, dynamic> json) => TripStop(
  id: json['id'] as String,
  clientStopId: json['client_stop_id'] as String,
  tripId: json['trip_id'] as String,
  sira: (json['sira'] as num).toInt(),
  firmaGirisAt: DateTime.parse(json['firma_giris_at'] as String),
  tripTypeId: json['trip_type_id'] as String?,
  requesterId: json['requester_id'] as String?,
  cikisNedeni: json['cikis_nedeni'] as String?,
  gidilenIl: json['gidilen_il'] as String?,
  gidilenIlce: json['gidilen_ilce'] as String?,
  gidilenSirketId: json['gidilen_sirket_id'] as String?,
  gidilenSirketFree: json['gidilen_sirket_free'] as String?,
  irsaliyeNoGiris: json['irsaliye_no_giris'] as String?,
  irsaliyeNoCikis: json['irsaliye_no_cikis'] as String?,
  firmaCikisAt: json['firma_cikis_at'] == null
      ? null
      : DateTime.parse(json['firma_cikis_at'] as String),
  onayDurumu:
      $enumDecodeNullable(_$OnayDurumuEnumMap, json['onay_durumu']) ??
      OnayDurumu.beklemede,
  onaylayanId: json['onaylayan_id'] as String?,
  onaylandiAt: json['onaylandi_at'] == null
      ? null
      : DateTime.parse(json['onaylandi_at'] as String),
  seferDurumu:
      $enumDecodeNullable(_$SeferDurumuEnumMap, json['sefer_durumu']) ??
      SeferDurumu.devamEdiyor,
  notlar: json['notlar'] as String?,
  notlarCikis: json['notlar_cikis'] as String?,
);

Map<String, dynamic> _$TripStopToJson(TripStop instance) => <String, dynamic>{
  'id': instance.id,
  'client_stop_id': instance.clientStopId,
  'trip_id': instance.tripId,
  'sira': instance.sira,
  'firma_giris_at': instance.firmaGirisAt.toIso8601String(),
  'trip_type_id': instance.tripTypeId,
  'requester_id': instance.requesterId,
  'cikis_nedeni': instance.cikisNedeni,
  'gidilen_il': instance.gidilenIl,
  'gidilen_ilce': instance.gidilenIlce,
  'gidilen_sirket_id': instance.gidilenSirketId,
  'gidilen_sirket_free': instance.gidilenSirketFree,
  'irsaliye_no_giris': instance.irsaliyeNoGiris,
  'irsaliye_no_cikis': instance.irsaliyeNoCikis,
  'firma_cikis_at': instance.firmaCikisAt?.toIso8601String(),
  'onay_durumu': instance.onayDurumu.toJson(),
  'onaylayan_id': instance.onaylayanId,
  'onaylandi_at': instance.onaylandiAt?.toIso8601String(),
  'sefer_durumu': instance.seferDurumu.toJson(),
  'notlar': instance.notlar,
  'notlar_cikis': instance.notlarCikis,
};

const _$OnayDurumuEnumMap = {
  OnayDurumu.beklemede: 'beklemede',
  OnayDurumu.onaylandi: 'onaylandi',
};

const _$SeferDurumuEnumMap = {
  SeferDurumu.devamEdiyor: 'devamEdiyor',
  SeferDurumu.basarili: 'basarili',
  SeferDurumu.basarisiz: 'basarisiz',
};
