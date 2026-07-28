import 'package:json_annotation/json_annotation.dart';

part 'driver_location.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DriverLocation {
  const DriverLocation({
    required this.driverId,
    required this.fullName,
    this.lat,
    this.lng,
    this.updatedAt,
  });

  final String driverId;
  final String fullName;

  /// Sofor henuz hic konum gondermediyse null (harita ekraninda "konum yok" olarak gosterilir).
  final double? lat;
  final double? lng;
  final DateTime? updatedAt;

  factory DriverLocation.fromJson(Map<String, dynamic> json) => _$DriverLocationFromJson(json);

  Map<String, dynamic> toJson() => _$DriverLocationToJson(this);
}
