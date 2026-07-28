import 'package:json_annotation/json_annotation.dart';

part 'requester.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Requester {
  const Requester({
    required this.id,
    required this.fullName,
    this.aktif = true,
    this.email,
  });

  final String id;
  final String fullName;
  final bool aktif;

  /// Bu talep edenin (Onay Verici) giris hesabi yok - onay/bildirim maili
  /// dogrudan bu adrese gonderilir, mailin icindeki "Onayla" butonu tek
  /// tikla onaylar (bkz. backend/approvals_approve.php).
  final String? email;

  factory Requester.fromJson(Map<String, dynamic> json) => _$RequesterFromJson(json);

  Map<String, dynamic> toJson() => _$RequesterToJson(this);
}
