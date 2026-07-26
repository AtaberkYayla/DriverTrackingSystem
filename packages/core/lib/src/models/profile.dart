import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';

part 'profile.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.role,
    this.phone,
    this.aktif = true,
  });

  final String id;
  final String fullName;
  final AppRole role;
  final String? phone;
  final bool aktif;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
