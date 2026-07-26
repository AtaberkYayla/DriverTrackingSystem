import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class IlBilgisi {
  const IlBilgisi({required this.il, required this.ilceler});

  final String il;
  final List<String> ilceler;

  bool get ilceZorunlu => ilceler.isNotEmpty;
}

/// `assets/il_ilce.json` icindeki il/ilce verisini yukler ve mobil/web
/// tarafinda internet olmadan (offline) calisan bir type-ahead icin sunar.
class TurkeyLocations {
  TurkeyLocations._(this._iller);

  final List<IlBilgisi> _iller;

  static TurkeyLocations? _instance;

  static Future<TurkeyLocations> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString('packages/core/assets/il_ilce.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final iller = (json['iller'] as List<dynamic>)
        .map((e) => IlBilgisi(
              il: e['il'] as String,
              ilceler: (e['ilceler'] as List<dynamic>).cast<String>(),
            ))
        .toList();
    _instance = TurkeyLocations._(iller);
    return _instance!;
  }

  List<String> get ilIsimleri => _iller.map((e) => e.il).toList();

  List<String> ilceleriGetir(String il) {
    final match = _iller.where((e) => e.il == il);
    if (match.isEmpty) return const [];
    return match.first.ilceler;
  }

  bool ilceZorunluMu(String il) => ilceleriGetir(il).isNotEmpty;

  List<String> ilAra(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return ilIsimleri;
    return ilIsimleri.where((il) => il.toLowerCase().contains(q)).toList();
  }

  List<String> ilceAra(String il, String query) {
    final all = ilceleriGetir(il);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((ilce) => ilce.toLowerCase().contains(q)).toList();
  }
}
