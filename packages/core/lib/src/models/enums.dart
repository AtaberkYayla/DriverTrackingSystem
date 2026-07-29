enum AppRole {
  driver,
  office,
  manager,
  admin,
  operator;

  static AppRole fromJson(String value) => AppRole.values.byName(value);

  String toJson() => name;
}

enum OnayDurumu {
  beklemede,
  onaylandi;

  static OnayDurumu fromJson(String value) => switch (value) {
        'BEKLEMEDE' => OnayDurumu.beklemede,
        'ONAYLANDI' => OnayDurumu.onaylandi,
        _ => throw ArgumentError('Bilinmeyen onay_durumu: $value'),
      };

  String toJson() => switch (this) {
        OnayDurumu.beklemede => 'BEKLEMEDE',
        OnayDurumu.onaylandi => 'ONAYLANDI',
      };
}

enum SeferDurumu {
  devamEdiyor,
  basarili,
  basarisiz;

  static SeferDurumu fromJson(String value) => switch (value) {
        'DEVAM_EDIYOR' => SeferDurumu.devamEdiyor,
        'BASARILI' => SeferDurumu.basarili,
        'BASARISIZ' => SeferDurumu.basarisiz,
        _ => throw ArgumentError('Bilinmeyen sefer_durumu: $value'),
      };

  String toJson() => switch (this) {
        SeferDurumu.devamEdiyor => 'DEVAM_EDIYOR',
        SeferDurumu.basarili => 'BASARILI',
        SeferDurumu.basarisiz => 'BASARISIZ',
      };
}
