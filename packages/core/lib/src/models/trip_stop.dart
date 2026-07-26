import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';

part 'trip_stop.g.dart';

/// Bir sefer (Trip) icindeki tek bir firma ziyareti. Sofor tarafindan
/// Firma Giris aninda doldurulan detaylari ve ofis/yonetimin onay/
/// degerlendirmesini tasir. Bir sefer icinde art arda birden fazla
/// TripStop olabilir (araya fabrika girmeden firma-firma gecisi).
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class TripStop {
  const TripStop({
    required this.id,
    required this.clientStopId,
    required this.tripId,
    required this.sira,
    required this.firmaGirisAt,
    this.tripTypeId,
    this.requesterId,
    this.cikisNedeni,
    this.gidilenIl,
    this.gidilenIlce,
    this.gidilenSirketId,
    this.gidilenSirketFree,
    this.irsaliyeNo,
    this.firmaCikisAt,
    this.onayDurumu = OnayDurumu.beklemede,
    this.onaylayanId,
    this.onaylandiAt,
    this.seferDurumu = SeferDurumu.devamEdiyor,
    this.notlar,
  });

  final String id;
  final String clientStopId;
  final String tripId;
  final int sira;

  final DateTime firmaGirisAt;
  final String? tripTypeId;
  final String? requesterId;
  final String? cikisNedeni;
  final String? gidilenIl;
  final String? gidilenIlce;
  final String? gidilenSirketId;
  final String? gidilenSirketFree;
  final String? irsaliyeNo;
  final DateTime? firmaCikisAt;

  final OnayDurumu onayDurumu;
  final String? onaylayanId;
  final DateTime? onaylandiAt;
  final SeferDurumu seferDurumu;
  final String? notlar;

  bool get acikMi => firmaCikisAt == null;

  factory TripStop.fromJson(Map<String, dynamic> json) => _$TripStopFromJson(json);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'client_stop_id': clientStopId,
      'trip_id': tripId,
      'sira': sira,
      'firma_giris_at': firmaGirisAt.toIso8601String(),
      'trip_type_id': tripTypeId,
      'requester_id': requesterId,
      'cikis_nedeni': cikisNedeni,
      'gidilen_il': gidilenIl,
      'gidilen_ilce': gidilenIlce,
      'gidilen_sirket_id': gidilenSirketId,
      'gidilen_sirket_free': gidilenSirketFree,
      'irsaliye_no': irsaliyeNo,
      'firma_cikis_at': firmaCikisAt?.toIso8601String(),
      'onay_durumu': onayDurumu.toJson(),
      'onaylayan_id': onaylayanId,
      'onaylandi_at': onaylandiAt?.toIso8601String(),
      'sefer_durumu': seferDurumu.toJson(),
      'notlar': notlar,
    };

    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  TripStop copyWith({
    DateTime? firmaCikisAt,
    OnayDurumu? onayDurumu,
    String? onaylayanId,
    DateTime? onaylandiAt,
    SeferDurumu? seferDurumu,
    String? notlar,
  }) {
    return TripStop(
      id: id,
      clientStopId: clientStopId,
      tripId: tripId,
      sira: sira,
      firmaGirisAt: firmaGirisAt,
      tripTypeId: tripTypeId,
      requesterId: requesterId,
      cikisNedeni: cikisNedeni,
      gidilenIl: gidilenIl,
      gidilenIlce: gidilenIlce,
      gidilenSirketId: gidilenSirketId,
      gidilenSirketFree: gidilenSirketFree,
      irsaliyeNo: irsaliyeNo,
      firmaCikisAt: firmaCikisAt ?? this.firmaCikisAt,
      onayDurumu: onayDurumu ?? this.onayDurumu,
      onaylayanId: onaylayanId ?? this.onaylayanId,
      onaylandiAt: onaylandiAt ?? this.onaylandiAt,
      seferDurumu: seferDurumu ?? this.seferDurumu,
      notlar: notlar ?? this.notlar,
    );
  }
}
