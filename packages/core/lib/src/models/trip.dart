import 'package:json_annotation/json_annotation.dart';

part 'trip.g.dart';

/// Bir soforun fabrikadan cikip fabrikaya donene kadarki sefer oturumu.
/// Fabrika Cikis opsiyoneldir (sofor evden dogrudan bir firmaya gidebilir);
/// sefer sadece Fabrika Giris ile kapanir ([fabrikaGirisAt] dolduğunda).
@JsonSerializable(fieldRename: FieldRename.snake)
class Trip {
  const Trip({
    required this.id,
    required this.clientTripId,
    required this.driverId,
    required this.vehicleId,
    required this.tarih,
    this.fabrikaCikisAt,
    this.fabrikaGirisAt,
    this.createdByUserId,
  });

  final String id;
  final String clientTripId;
  final String driverId;
  final String vehicleId;
  final String tarih;
  final DateTime? fabrikaCikisAt;
  final DateTime? fabrikaGirisAt;

  /// admin_web'den elle (manager/admin/operator tarafindan) olusturulan
  /// seferlerde kim olusturduysa o kullanicinin id'sini tutar; driver_app'ten
  /// gelen seferlerde hep null'dur. Operator'un sadece kendi olusturdugu
  /// seferi duzenleyebilmesi bu alana gore arayuzde de yansitilir.
  final String? createdByUserId;

  bool get aktifMi => fabrikaGirisAt == null;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'client_trip_id': clientTripId,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'tarih': tarih,
      'fabrika_cikis_at': fabrikaCikisAt?.toIso8601String(),
      'fabrika_giris_at': fabrikaGirisAt?.toIso8601String(),
    };

    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  Trip copyWith({DateTime? fabrikaCikisAt, DateTime? fabrikaGirisAt}) {
    return Trip(
      id: id,
      clientTripId: clientTripId,
      driverId: driverId,
      vehicleId: vehicleId,
      tarih: tarih,
      fabrikaCikisAt: fabrikaCikisAt ?? this.fabrikaCikisAt,
      fabrikaGirisAt: fabrikaGirisAt ?? this.fabrikaGirisAt,
    );
  }
}
