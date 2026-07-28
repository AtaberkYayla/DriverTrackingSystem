import 'package:flutter/material.dart';

/// [Autocomplete] icin, klavye acikken listenin klavyenin arkasinda kalmasini
/// (yukari acilarak) onlemek yerine - liste HER ZAMAN alanin altinda acilir
/// ve kullanici listeyi kaydirmaya basladiginda klavye otomatik kapanir
/// (bkz. keyboardDismissBehavior). Boylece hem liste hep asagida kalir hem
/// de kaydirarak gizli kalan secenekler acilabilir.
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
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
  );
}
