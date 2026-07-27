import 'package:json_annotation/json_annotation.dart';

part 'requester.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Requester {
  const Requester({
    required this.id,
    required this.fullName,
    this.aktif = true,
    this.profileId,
  });

  final String id;
  final String fullName;
  final bool aktif;

  /// Bu talep edenin onay vermesi gereken hesabi (profiles.id). Sefer
  /// listesinde Onay Verici rolundeki kullanicilar sadece kendi profileId'si
  /// buraya baglanan talep edenlerin durak kayitlarini gorur.
  final String? profileId;

  factory Requester.fromJson(Map<String, dynamic> json) => _$RequesterFromJson(json);

  Map<String, dynamic> toJson() => _$RequesterToJson(this);
}
