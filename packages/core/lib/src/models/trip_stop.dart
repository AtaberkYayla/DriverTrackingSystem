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
    this.irsaliyeNoGiris,
    this.irsaliyeNoCikis,
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
  final String? irsaliyeNoGiris;
  final String? irsaliyeNoCikis;
  final DateTime? firmaCikisAt;

  final OnayDurumu onayDurumu;
  final String? onaylayanId;
  final DateTime? onaylandiAt;
  final SeferDurumu seferDurumu;
  final String? notlar;

  bool get acikMi => firmaCikisAt == null;

  // `_$TripStopFromJson` decode edilmiyor: json_serializable enum alanlarini
  // Dart uye adiyla ('beklemede') cozer, ama DB'deki onay_durumu/sefer_durumu
  // degerleri buyuk harfli DB kodlaridir ('BEKLEMEDE') ve OnayDurumu.fromJson /
  // SeferDurumu.fromJson'a ihtiyac duyar; aksi halde sunucudan gelen her satirda
  // "is not one of the supported values" hatasi alinir.
  factory TripStop.fromJson(Map<String, dynamic> json) => TripStop(
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
        onayDurumu: json['onay_durumu'] == null
            ? OnayDurumu.beklemede
            : OnayDurumu.fromJson(json['onay_durumu'] as String),
        onaylayanId: json['onaylayan_id'] as String?,
        onaylandiAt: json['onaylandi_at'] == null
            ? null
            : DateTime.parse(json['onaylandi_at'] as String),
        seferDurumu: json['sefer_durumu'] == null
            ? SeferDurumu.devamEdiyor
            : SeferDurumu.fromJson(json['sefer_durumu'] as String),
        notlar: json['notlar'] as String?,
      );

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
      'irsaliye_no_giris': irsaliyeNoGiris,
      'irsaliye_no_cikis': irsaliyeNoCikis,
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
    int? sira,
    DateTime? firmaGirisAt,
    String? tripTypeId,
    String? requesterId,
    String? cikisNedeni,
    String? gidilenIl,
    String? gidilenIlce,
    String? gidilenSirketId,
    String? gidilenSirketFree,
    String? irsaliyeNoGiris,
    String? irsaliyeNoCikis,
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
      sira: sira ?? this.sira,
      firmaGirisAt: firmaGirisAt ?? this.firmaGirisAt,
      tripTypeId: tripTypeId ?? this.tripTypeId,
      requesterId: requesterId ?? this.requesterId,
      cikisNedeni: cikisNedeni ?? this.cikisNedeni,
      gidilenIl: gidilenIl ?? this.gidilenIl,
      gidilenIlce: gidilenIlce ?? this.gidilenIlce,
      gidilenSirketId: gidilenSirketId ?? this.gidilenSirketId,
      gidilenSirketFree: gidilenSirketFree ?? this.gidilenSirketFree,
      irsaliyeNoGiris: irsaliyeNoGiris ?? this.irsaliyeNoGiris,
      irsaliyeNoCikis: irsaliyeNoCikis ?? this.irsaliyeNoCikis,
      firmaCikisAt: firmaCikisAt ?? this.firmaCikisAt,
      onayDurumu: onayDurumu ?? this.onayDurumu,
      onaylayanId: onaylayanId ?? this.onaylayanId,
      onaylandiAt: onaylandiAt ?? this.onaylandiAt,
      seferDurumu: seferDurumu ?? this.seferDurumu,
      notlar: notlar ?? this.notlar,
    );
  }
}
