import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Gidilebilecek lokasyonlar bu sekiz il ile sinirlidir (bkz. driver_app'teki
/// ayni isimli/amacli liste). Izmir ve Manisa icin il_ilce.json'da gercek
/// ilce listesi bulundugundan secim zorunlu bir listeden yapilir, digerlerinde
/// ilce verisi olmadigi icin serbest metin olarak (istege bagli) girilir.
const izinVerilenIller = <String>[
  'İzmir',
  'Manisa',
  'İstanbul',
  'Bursa',
  'Konya',
  'Aydın',
  'Aksaray',
  'Tekirdağ',
];

/// Secili seyahat turune (kategoriye) etiketlenmis sirketleri filtreler; henuz
/// bir tur secilmemisse (tripTypeId null) tum sirketler gosterilir.
List<Company> turUyumluSirketler(List<Company> companies, String? tripTypeId) {
  if (tripTypeId == null) return companies;
  return companies.where((c) => c.tripTypeIds.contains(tripTypeId)).toList();
}

/// "Gidilen İl"/"Gidilen İlçe" alan çifti: il, sabit [izinVerilenIller]
/// listesinden seçilir (serbest metne izin verilmez); İzmir/Manisa için ilçe
/// de il_ilce.json'daki listeden seçilir, diğerlerinde ilçe serbest metindir.
/// "Durak Ekle" formlarının hepsinde (create_trip_screen, trip_edit_screen,
/// quick_actions) aynı davranışı sağlamak için paylaşılır.
class IlIlceSecici extends StatefulWidget {
  const IlIlceSecici({
    super.key,
    required this.turkey,
    required this.ilController,
    required this.ilceController,
  });

  final TurkeyLocations turkey;
  final TextEditingController ilController;
  final TextEditingController ilceController;

  @override
  State<IlIlceSecici> createState() => _IlIlceSeciciState();
}

class _IlIlceSeciciState extends State<IlIlceSecici> {
  String? _seciliIl;

  @override
  void initState() {
    super.initState();
    _seciliIl =
        izinVerilenIller.contains(widget.ilController.text) ? widget.ilController.text : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (value) {
            if (value.text.isEmpty) return izinVerilenIller;
            final q = value.text.toLowerCase();
            return izinVerilenIller.where((il) => il.toLowerCase().contains(q));
          },
          onSelected: (il) => setState(() {
            _seciliIl = il;
            widget.ilController.text = il;
            widget.ilceController.clear();
          }),
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            controller.text = widget.ilController.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: 'Gidilen İl', border: OutlineInputBorder()),
              onChanged: (v) {
                widget.ilController.text = v;
                if (_seciliIl != v) {
                  setState(() {
                    _seciliIl = null;
                    widget.ilceController.clear();
                  });
                }
              },
            );
          },
        ),
        if (_seciliIl != null) ...[
          const SizedBox(height: 16),
          if (widget.turkey.ilceZorunluMu(_seciliIl!))
            Autocomplete<String>(
              key: ValueKey('ilce-$_seciliIl'),
              optionsBuilder: (value) => widget.turkey.ilceAra(_seciliIl!, value.text),
              onSelected: (ilce) => widget.ilceController.text = ilce,
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                controller.text = widget.ilceController.text;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration:
                      const InputDecoration(labelText: 'Gidilen İlçe', border: OutlineInputBorder()),
                  onChanged: (v) => widget.ilceController.text = v,
                );
              },
            )
          else
            TextFormField(
              controller: widget.ilceController,
              decoration: const InputDecoration(
                  labelText: 'Gidilen İlçe (opsiyonel)', border: OutlineInputBorder()),
            ),
        ],
      ],
    );
  }
}
