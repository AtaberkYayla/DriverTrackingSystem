import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Bir Excel hucresinin degeri: metin, sayi veya bos.
sealed class XlsxCell {
  const XlsxCell();
}

class XlsxText extends XlsxCell {
  const XlsxText(this.value, {this.bold = false});
  final String value;
  final bool bold;
}

class XlsxNumber extends XlsxCell {
  const XlsxNumber(this.value);
  final num value;
}

/// Bir sutunun icerigine gore otomatik genislik hesaplar (Excel'in "sutun
/// genisligini otomatik sigdir" ozelligine benzer): o sutundaki en uzun
/// metnin karakter sayisi + bir miktar bosluk payi, asiri genis/dar
/// sutunlari onlemek icin [minWidth]-[maxWidth] araligina sikistirilir.
List<double> _autoFitColumnWidths(
  List<List<XlsxCell>> rows, {
  double minWidth = 8,
  double maxWidth = 80,
  double padding = 2,
}) {
  final columnCount = rows.fold<int>(0, (m, row) => row.length > m ? row.length : m);
  final maxChars = List<int>.filled(columnCount, 0);
  for (final row in rows) {
    for (var c = 0; c < row.length; c++) {
      final text = switch (row[c]) {
        XlsxText(:final value) => value,
        XlsxNumber(:final value) => value.toString(),
      };
      if (text.length > maxChars[c]) maxChars[c] = text.length;
    }
  }
  return [
    for (final chars in maxChars) (chars + padding).clamp(minWidth, maxWidth).toDouble(),
  ];
}

/// Minimal, bagimliliksiz (harici 'excel' paketi olmadan) tek sayfalik bir
/// .xlsx (OOXML SpreadsheetML) dosyasi uretir. `pdf` paketinin transitive
/// bagimliligi olan `archive` ile ZIP konteynerini olusturur; hucre
/// icerikleri sharedStrings.xml karmasikligina girmeden dogrudan
/// t="inlineStr" olarak yazilir.
///
/// [columnWidths] verilmezse, sutun genislikleri icerige gore otomatik
/// hesaplanir (bkz. [_autoFitColumnWidths]) - boylece hicbir hucre metni
/// Excel'de acilirken kirpilmis gorunmez.
Uint8List buildSimpleXlsx({
  required List<List<XlsxCell>> rows,
  String sheetName = 'Sayfa1',
  List<double>? columnWidths,
}) {
  final effectiveColumnWidths = columnWidths ?? _autoFitColumnWidths(rows);

  String xmlEscape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  String colName(int index) {
    var n = index;
    var name = '';
    while (n >= 0) {
      name = String.fromCharCode(65 + (n % 26)) + name;
      n = (n ~/ 26) - 1;
    }
    return name;
  }

  final sheetBuffer = StringBuffer();
  sheetBuffer.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
  sheetBuffer.write(
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
  if (effectiveColumnWidths.isNotEmpty) {
    sheetBuffer.write('<cols>');
    for (var i = 0; i < effectiveColumnWidths.length; i++) {
      sheetBuffer.write(
          '<col min="${i + 1}" max="${i + 1}" width="${effectiveColumnWidths[i]}" customWidth="1"/>');
    }
    sheetBuffer.write('</cols>');
  }
  sheetBuffer.write('<sheetData>');
  for (var r = 0; r < rows.length; r++) {
    sheetBuffer.write('<row r="${r + 1}">');
    final row = rows[r];
    for (var c = 0; c < row.length; c++) {
      final cellRef = '${colName(c)}${r + 1}';
      final cell = row[c];
      switch (cell) {
        case XlsxText(:final value, :final bold):
          final style = bold ? ' s="1"' : '';
          sheetBuffer.write('<c r="$cellRef" t="inlineStr"$style>'
              '<is><t xml:space="preserve">${xmlEscape(value)}</t></is></c>');
        case XlsxNumber(:final value):
          sheetBuffer.write('<c r="$cellRef"><v>$value</v></c>');
      }
    }
    sheetBuffer.write('</row>');
  }
  sheetBuffer.write('</sheetData></worksheet>');

  const contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
      '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
      '</Types>';

  const rootRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
      '</Relationships>';

  final workbook = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<sheets><sheet name="${xmlEscape(sheetName)}" sheetId="1" r:id="rId1"/></sheets>'
      '</workbook>';

  const workbookRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
      '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
      '</Relationships>';

  const styles = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<fonts count="2">'
      '<font><sz val="11"/><name val="Calibri"/></font>'
      '<font><b/><sz val="11"/><name val="Calibri"/></font>'
      '</fonts>'
      '<fills count="1"><fill><patternFill patternType="none"/></fill></fills>'
      '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
      '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
      '<cellXfs count="2">'
      '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
      '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
      '</cellXfs>'
      '</styleSheet>';

  final archive = Archive()
    ..addFile(ArchiveFile.string('[Content_Types].xml', contentTypes))
    ..addFile(ArchiveFile.string('_rels/.rels', rootRels))
    ..addFile(ArchiveFile.string('xl/workbook.xml', workbook))
    ..addFile(ArchiveFile.string('xl/_rels/workbook.xml.rels', workbookRels))
    ..addFile(ArchiveFile.string('xl/styles.xml', styles))
    ..addFile(ArchiveFile.string('xl/worksheets/sheet1.xml', sheetBuffer.toString()));

  return ZipEncoder().encodeBytes(archive);
}
