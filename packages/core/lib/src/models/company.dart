import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Company {
  const Company({
    required this.id,
    required this.name,
    this.sehir,
    this.aktif = true,
  });

  final String id;
  final String name;
  final String? sehir;
  final bool aktif;

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
