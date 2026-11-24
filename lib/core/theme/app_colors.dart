import 'package:flutter/material.dart';

/// Palette FasoCarbu : un orange carburant comme couleur de marque
/// sur une base de gris neutres. Mêmes valeurs que l'appli mobile.
class AppColors {
  AppColors._();

  // Marque
  static const brand = Color(0xFFEA580C); // orange 600
  static const brandHover = Color(0xFFC2410C); // orange 700
  static const brandSoft = Color(0xFFFFF1E8); // fond léger
  static const brandOnDark = Color(0xFFFB923C); // orange 400, lisible sur fond sombre

  // Neutres (clair)
  static const bg = Color(0xFFF7F7F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF2F3F5);
  static const border = Color(0xFFE4E5E9);
  static const textPrimary = Color(0xFF18181B);
  static const textSecondary = Color(0xFF52525B);
  static const textMuted = Color(0xFF8A8A93);

  // Neutres (sombre)
  static const bgDark = Color(0xFF0E0F11);
  static const surfaceDark = Color(0xFF17181B);
  static const surfaceMutedDark = Color(0xFF1F2024);
  static const borderDark = Color(0xFF2A2B30);
  static const textPrimaryDark = Color(0xFFF4F4F5);
  static const textSecondaryDark = Color(0xFFB4B4BB);
  static const textMutedDark = Color(0xFF7C7C85);

  // Sémantique
  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFE8F7EE);
  static const warning = Color(0xFFD97706);
  static const warningSoft = Color(0xFFFEF5E3);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFDECEC);
  static const info = Color(0xFF2563EB);
  static const infoSoft = Color(0xFFEAF1FE);

  // Barre latérale (toujours sombre)
  static const sidebar = Color(0xFF141518);
  static const sidebarHover = Color(0xFF1F2024);
  static const sidebarText = Color(0xFFA1A1AA);
}
