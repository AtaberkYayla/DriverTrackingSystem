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

  /// [tarih] sunucuda/sirlamada kullanilan "yyyy-MM-dd" bicimindedir;
  /// arayuzde her yerde gg.aa.yyyy gosterilmesi icin bu getter kullanilir.
  String get tarihGosterim => isoTarihToGosterim(tarih);

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

/// Sunucuda/sirlamada kullanilan "yyyy-MM-dd" bicimindeki bir tarihi,
/// arayuzde standart olarak kullanilan gg.aa.yyyy bicimine cevirir.
/// [Trip.tarih] disinda, aracin yerel veritabani (driver_app) gibi ayni
/// ham bicimi tasiyan diger yerlerde de kullanilabilsin diye top-level
/// bir fonksiyon olarak tanimlanir. Beklenmeyen bir bicimle karsilasilirsa
/// (ör. bos veri) girdi oldugu gibi dondurulur.
String isoTarihToGosterim(String isoTarih) {
  final parcalar = isoTarih.split('-');
  if (parcalar.length != 3) return isoTarih;
  final [yil, ay, gun] = parcalar;
  return '$gun.$ay.$yil';
}
