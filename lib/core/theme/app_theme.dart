import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Espacements et rayons communs : utiliser ces constantes plutôt que des
/// valeurs en dur pour garder une interface cohérente.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
}

/// Ombres douces communes (mode clair uniquement : en sombre, les bordures
/// suffisent).
class AppShadows {
  AppShadows._();
  static List<BoxShadow> soft(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const []
      : [
          BoxShadow(color: const Color(0xFF18181B).withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: const Color(0xFF18181B).withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ];

  static List<BoxShadow> brand() => [
        BoxShadow(color: const Color(0xFFEA580C).withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 10)),
      ];
}

/// Dégradé de marque (orange -> ambre), utilisé pour les en-têtes et le logo.
const brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
);

/// Dégradé sombre des panneaux de marque (connexion, en-têtes mobiles).
const inkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1C1917), Color(0xFF292524), Color(0xFF431407)],
  stops: [0, 0.55, 1],
);

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bg;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final surfaceMuted = isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMuted;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final brand = isDark ? AppColors.brandOnDark : AppColors.brand;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: brand,
      onPrimary: isDark ? AppColors.textPrimary : Colors.white,
      primaryContainer: isDark ? const Color(0xFF3A2112) : AppColors.brandSoft,
      onPrimaryContainer: isDark ? AppColors.brandOnDark : AppColors.brandHover,
      secondary: textSecondary,
      onSecondary: surface,
      // Utilisé par les puces et segments sélectionnés
      secondaryContainer: isDark ? const Color(0xFF3A2112) : AppColors.brandSoft,
      onSecondaryContainer: isDark ? AppColors.brandOnDark : AppColors.brandHover,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: bg,
      surfaceContainerLow: bg,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceMuted,
      surfaceContainerHighest: surfaceMuted,
      outline: border,
      outlineVariant: border,
    );

    final base = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    final text = base.copyWith(
      displaySmall: base.displaySmall?.copyWith(fontSize: 30, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.8),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.6),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.2),
      titleLarge: base.titleLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: base.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
      titleSmall: base.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 15, color: textPrimary),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: textSecondary),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12.5, color: textMuted),
      labelLarge: base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w500, color: textSecondary),
      labelSmall: base.labelSmall?.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600, color: textMuted, letterSpacing: 0.4),
    );

    OutlineInputBorder outline(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c, width: w),
        );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
    const buttonPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: surface,
      textTheme: text,
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
        shape: Border(bottom: BorderSide(color: border)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 1.5,
        shadowColor: const Color(0xFF18181B).withValues(alpha: 0.10),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: text.bodyMedium?.copyWith(color: textMuted),
        labelStyle: text.bodyMedium,
        floatingLabelStyle: text.bodyMedium?.copyWith(color: brand),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        border: outline(border),
        enabledBorder: outline(border),
        focusedBorder: outline(brand, 1.5),
        errorBorder: outline(AppColors.danger),
        focusedErrorBorder: outline(AppColors.danger, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: scheme.onPrimary,
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: text.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: isDark ? const Color(0xFF3A2112) : AppColors.brandSoft,
        secondaryLabelStyle: text.labelMedium?.copyWith(color: brand, fontWeight: FontWeight.w600),
        side: BorderSide(color: border),
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.surfaceMutedDark : AppColors.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        width: 420,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: text.labelSmall,
        dataTextStyle: text.bodyMedium?.copyWith(color: textPrimary),
        headingRowHeight: 44,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 60,
        dividerThickness: 1,
        horizontalMargin: AppSpacing.lg,
        columnSpacing: AppSpacing.xl,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: text.bodySmall?.copyWith(color: Colors.white),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: brand),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isDark ? const Color(0xFF3A2112) : AppColors.brandSoft,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? brand : textMuted, size: 24),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium?.copyWith(
            color: s.contains(WidgetState.selected) ? brand : textMuted,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
      ),
    );
  }
}
