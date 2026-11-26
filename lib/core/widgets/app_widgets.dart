import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Tonalités sémantiques partagées par badges, cartes et messages.
enum Tone { neutral, brand, success, warning, danger, info }

extension ToneColors on Tone {
  Color get fg => switch (this) {
        Tone.neutral => AppColors.textSecondary,
        Tone.brand => AppColors.brand,
        Tone.success => AppColors.success,
        Tone.warning => AppColors.warning,
        Tone.danger => AppColors.danger,
        Tone.info => AppColors.info,
      };

  Color softBg(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark) return fg.withValues(alpha: 0.16);
    return switch (this) {
      Tone.neutral => AppColors.surfaceMuted,
      Tone.brand => AppColors.brandSoft,
      Tone.success => AppColors.successSoft,
      Tone.warning => AppColors.warningSoft,
      Tone.danger => AppColors.dangerSoft,
      Tone.info => AppColors.infoSoft,
    };
  }
}

/// Associe les statuts métier du backend à un libellé et une tonalité.
({String label, Tone tone}) statusInfo(String? raw) {
  final s = (raw ?? '').toUpperCase().trim();
  switch (s) {
    case 'EN_ATTENTE':
      return (label: 'En attente', tone: Tone.warning);
    case 'VALIDEE':
    case 'VALIDER':
    case 'VALIDE':
      return (label: 'Validé', tone: Tone.success);
    case 'REJETEE':
    case 'REJETER':
    case 'REJETE':
      return (label: 'Rejeté', tone: Tone.danger);
    case 'CONSOMMEE':
    case 'TERMINEE':
      return (label: 'Consommé', tone: Tone.info);
    case 'EN_COURS':
      return (label: 'En cours', tone: Tone.brand);
    case 'ANNULEE':
      return (label: 'Annulé', tone: Tone.neutral);
    case 'ACTIF':
      return (label: 'Active', tone: Tone.success);
    case 'INACTIF':
      return (label: 'Inactive', tone: Tone.neutral);
    default:
      return (label: raw == null || raw.isEmpty ? '—' : raw, tone: Tone.neutral);
  }
}

// ---------------------------------------------------------------------------
// En-tête de page
// ---------------------------------------------------------------------------

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const [], this.eyebrow});

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  /// Petit libellé au-dessus du titre (rubrique, fil d'Ariane).
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 640;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: t.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
        ],
        Text(title, style: t.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: t.bodyMedium),
        ],
      ],
    );
    final actionRow = Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: actions);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: narrow || actions.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                if (actions.isNotEmpty) ...[const SizedBox(height: AppSpacing.lg), actionRow],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Expanded(child: heading), actionRow],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cartes
// ---------------------------------------------------------------------------

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hasHeader = title != null || trailing != null;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null) Text(title!, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: t.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          if (hasHeader) const Divider(),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tone = Tone.brand,
    this.hint,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Tone tone;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Halo coloré discret dans le coin, pour donner du relief.
            Positioned(
              right: -28,
              top: -28,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(shape: BoxShape.circle, color: tone.fg.withValues(alpha: 0.07)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl - 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [tone.fg, Color.lerp(tone.fg, Colors.white, 0.28)!],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [BoxShadow(color: tone.fg.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Icon(icon, size: 21, color: Colors.white),
                    ),
                    const Spacer(),
                    if (onTap != null) Icon(Icons.arrow_outward_rounded, size: 18, color: t.bodySmall?.color),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  Text(value, style: t.displaySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(label, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  if (hint != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: tone.softBg(context), borderRadius: BorderRadius.circular(999)),
                      child: Text(hint!, style: t.labelMedium?.copyWith(color: tone.fg, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grille responsive : 1 à [maxColumns] colonnes selon la largeur disponible.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 240,
    this.maxColumns = 4,
    this.spacing = AppSpacing.lg,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = (c.maxWidth / minItemWidth).floor().clamp(1, maxColumns);
      final w = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final child in children) SizedBox(width: w, child: child)],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Badges, avatars
// ---------------------------------------------------------------------------

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = Tone.neutral});

  /// Badge construit directement depuis un statut backend (EN_ATTENTE, ...).
  factory StatusBadge.fromStatus(String? status, {Key? key}) {
    final i = statusInfo(status);
    return StatusBadge(key: key, label: i.label, tone: i.tone);
  }

  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.softBg(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: tone.fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: tone.fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 36, this.imageUrl});

  final String name;
  final double size;
  final String? imageUrl;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// États : chargement, vide, erreur
// ---------------------------------------------------------------------------

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(message!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final brand = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pictogramme dans des cercles concentriques aux couleurs de la marque.
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(shape: BoxShape.circle, color: brand.withValues(alpha: 0.06)),
                alignment: Alignment.center,
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: brand.withValues(alpha: 0.12)),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 28, color: brand),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: t.titleMedium, textAlign: TextAlign.center),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(message!, style: t.bodyMedium, textAlign: TextAlign.center),
              ],
              if (action != null) ...[const SizedBox(height: AppSpacing.xl), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Une erreur est survenue',
      message: message,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
            ),
    );
  }
}

/// Bandeau d'alerte en ligne (erreur de formulaire, information...).
class InlineAlert extends StatelessWidget {
  const InlineAlert({super.key, required this.message, this.tone = Tone.danger});
  final String message;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final icon = switch (tone) {
      Tone.success => Icons.check_circle_outline_rounded,
      Tone.warning => Icons.warning_amber_rounded,
      Tone.info => Icons.info_outline_rounded,
      _ => Icons.error_outline_rounded,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tone.softBg(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tone.fg),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tone.fg)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Champs et barres d'outils
// ---------------------------------------------------------------------------

class SearchField extends StatelessWidget {
  const SearchField({super.key, this.hint = 'Rechercher…', this.onChanged, this.controller, this.width = 280});
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
        ),
      ),
    );
  }
}

/// Libellé au-dessus d'un champ de formulaire.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(TextSpan(
        text: text,
        style: t.titleSmall,
        children: [if (required) const TextSpan(text: ' *', style: TextStyle(color: AppColors.danger))],
      )),
    );
  }
}

/// Champ texte avec libellé au-dessus, utilisé dans tous les formulaires.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.required = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final bool required;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(label, required: required),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator ??
              (required ? (v) => (v == null || v.trim().isEmpty) ? 'Ce champ est requis' : null : null),
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Liste déroulante avec libellé au-dessus.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.icon,
    this.required = false,
    this.validator,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? hint;
  final IconData? icon;
  final bool required;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(label, required: required),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          borderRadius: BorderRadius.circular(AppRadius.md),
          validator: validator ?? (required ? (v) => v == null ? 'Ce champ est requis' : null : null),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }
}

/// Bouton principal avec état de chargement.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: AppSpacing.sm)],
              Text(label),
            ],
          );
    final button = FilledButton(onPressed: loading ? null : onPressed, child: child);
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Mise en page des formulaires : carte centrée à largeur maximale.
class FormLayout extends StatelessWidget {
  const FormLayout({super.key, required this.children, this.maxWidth = 760, this.footer});
  final List<Widget> children;
  final double maxWidth;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._spaced(children),
                if (footer != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(),
                  const SizedBox(height: AppSpacing.lg),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<Widget> _spaced(List<Widget> items) => [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          items[i],
        ],
      ];
}

/// Deux champs côte à côte sur grand écran, empilés sur mobile.
class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 520) {
        return Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            children[i],
          ],
        ]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.lg),
            Expanded(child: children[i]),
          ],
        ],
      );
    });
  }
}

/// Tableau de données dans une carte, défilant horizontalement si besoin.
class AppDataTable extends StatelessWidget {
  const AppDataTable({super.key, required this.columns, required this.rows});
  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: c.maxWidth),
          child: DataTable(
            columns: columns,
            rows: rows,
            headingRowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainerHigh),
          ),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Dialogues et notifications
// ---------------------------------------------------------------------------

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmer',
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.onSurfaceVariant),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: destructive ? FilledButton.styleFrom(backgroundColor: AppColors.danger) : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void showAppSnack(BuildContext context, String message, {Tone tone = Tone.neutral}) {
  final icon = switch (tone) {
    Tone.success => Icons.check_circle_rounded,
    Tone.danger => Icons.error_rounded,
    Tone.warning => Icons.warning_rounded,
    _ => Icons.info_rounded,
  };
  final color = tone == Tone.neutral ? Colors.white70 : tone.fg;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(message)),
      ]),
    ));
}

String formatDate(DateTime? d, {bool withTime = false}) {
  if (d == null) return '—';
  String two(int n) => n.toString().padLeft(2, '0');
  final date = '${two(d.day)}/${two(d.month)}/${d.year}';
  return withTime ? '$date · ${two(d.hour)}:${two(d.minute)}' : date;
}

String formatNumber(num? n, {int decimals = 0}) {
  if (n == null) return '—';
  final s = n.toStringAsFixed(decimals);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
  return parts.length > 1 ? '$intPart,${parts[1]}' : intPart;
}

/// Lien « ← Retour » affiché au-dessus des pages de formulaire.
class BackLink extends StatelessWidget {
  const BackLink({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: TextButton.icon(
          onPressed: onTap ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
        ),
      ),
    );
  }
}
