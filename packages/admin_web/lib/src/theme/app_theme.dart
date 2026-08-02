import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// admin_web'in tek tema tanımı. Amaç: her ekranda tekrarlanan
/// `border: OutlineInputBorder()`, `Card`/`AppBar`/`Dialog` görünümlerini tek
/// yerde toplayıp Material 3'ün çıplak varsayılanının ötesinde tutarlı,
/// kurumsal bir görünüm vermek. Marka rengi (DedemBrand.red) aynı kalıyor;
/// burada sadece o rengin etrafına bir tasarım dili kuruluyor.
class AppTheme {
  AppTheme._();

  static const _radius = 10.0;

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DedemBrand.red,
      brightness: Brightness.light,
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: VisualDensity.standard,

      textTheme: _textTheme(colorScheme),

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),

      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(_radius)),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: shape),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, space: 1),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    const base = Typography.blackMountainView;
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(color: colorScheme.onSurface),
      bodyMedium: base.bodyMedium?.copyWith(color: colorScheme.onSurface),
    );
  }
}
