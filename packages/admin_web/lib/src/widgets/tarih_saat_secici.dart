import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

/// Bir DateTime alanini (tarih + saat) tek satirda gosterip duzenlemeyi
/// saglayan ortak widget. create_trip_screen, trip_edit_screen ve hizli
/// islem dialoglarinin hepsinde kullanilir.
///
/// Onceki surumde saat secimi tek bir ortak "sefer tarihi"ne baglaniyordu;
/// artik her alan kendi tarihini de sorar, boylece gece yarisini gecen
/// hareketler (ör. 30 Temmuz'da cikip 31 Temmuz'da firmaya giren) dogru
/// tarihlenebilir.
///
/// `showTimePicker`'a `alwaysUse24HourFormat: true` zorlanmazsa, Flutter
/// web'de saat girisi tarayicinin/OS'un saat formati ayarina gore 1-12 ile
/// sinirlanabiliyor (bkz. Flutter SDK time_picker.dart _parseHour) - bu
/// widget bunu duzeltir.
class TarihSaatSecici extends StatelessWidget {
  const TarihSaatSecici({
    super.key,
    required this.label,
    required this.deger,
    required this.onChanged,
  });

  final String label;
  final DateTime? deger;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _sec(BuildContext context) async {
    final simdi = DateTime.now();
    final tarih = await showDatePicker(
      context: context,
      initialDate: deger ?? simdi,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: '$label tarihi',
    );
    if (tarih == null) return;
    if (!context.mounted) return;
    final saat = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(deger ?? simdi),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: '$label saati (${DateFormat('dd.MM.yyyy').format(tarih)})',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (saat == null) return;
    onChanged(DateTime(tarih.year, tarih.month, tarih.day, saat.hour, saat.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('$label: ${deger == null ? '-' : _dateFormat.format(deger!)}'),
        ),
        TextButton(
          onPressed: () => _sec(context),
          child: const Text('Seç'),
        ),
        if (deger != null)
          TextButton(onPressed: () => onChanged(null), child: const Text('Temizle')),
      ],
    );
  }
}
