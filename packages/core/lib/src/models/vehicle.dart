import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Vehicle {
  const Vehicle({
    required this.id,
    required this.plaka,
    this.aciklama,
    this.aktif = true,
  });

  final String id;
  final String plaka;
  final String? aciklama;
  final bool aktif;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
