import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [Autocomplete] icin, klavye acikken listenin klavyenin arkasinda kalmasini
/// (yukari acilarak) onlemek yerine - liste HER ZAMAN alanin altinda acilir
/// ve kullanici listeyi kaydirmaya basladiginda klavye otomatik kapanir.
///
/// Bunu ScrollView'in kendi keyboardDismissBehavior.onDrag'i ile DEGIL, elle
/// yapiyoruz: onDrag dahili olarak alanin focus'unu da kaldiriyor, ama
/// Autocomplete secenek listesini sadece alan focus'luyken acik tutuyor - bu
/// da suruklemenin ortasinda listenin (overlay) yok edilmesine, yani
/// kullanicinin "klavye kapaniyor ama liste donup kaliyor" sikayetine yol
/// aciyordu. Burada sadece ekran klavyesini gizliyoruz, focus'u KORUYORUZ ki
/// liste acik ve secilebilir kalsin.
Widget buildAutocompleteOptionsView<T extends Object>({
  required Iterable<T> options,
  required AutocompleteOnSelected<T> onSelected,
  required AutocompleteOptionToString<T> displayStringForOption,
  double optionsMaxHeight = 200.0,
}) {
  return Material(
    elevation: 4.0,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: optionsMaxHeight),
      child: NotificationListener<ScrollStartNotification>(
        onNotification: (notification) {
          if (notification.dragDetails != null) {
            SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options.elementAt(index);
            return InkWell(
              onTap: () => onSelected(option),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(displayStringForOption(option)),
              ),
            );
          },
        ),
      ),
    ),
  );
}
