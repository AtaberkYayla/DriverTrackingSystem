import 'package:json_annotation/json_annotation.dart';

part 'manager.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Manager {
  const Manager({
    required this.id,
    required this.fullName,
    this.aktif = true,
  });

  final String id;
  final String fullName;
  final bool aktif;

  factory Manager.fromJson(Map<String, dynamic> json) => _$ManagerFromJson(json);

  Map<String, dynamic> toJson() => _$ManagerToJson(this);
}
