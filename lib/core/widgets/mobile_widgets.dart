import 'package:flutter/material.dart';

import '../notification_store.dart';
import '../session.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';
import 'logo.dart';
import 'ticket_card.dart';

export 'logo.dart' show Logo, LogoMark;
export 'ticket_card.dart' show TicketCard, TicketData;

/// Logo FasoCarbu : pictogramme + nom.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 34, this.onDark = false, this.showName = true});
  final double size;
  final bool onDark;
  final bool showName;

  @override
  Widget build(BuildContext context) => showName ? Logo(size: size, onDark: onDark) : LogoMark(size: size);
}

/// En-tête sombre aux couleurs de la marque (accueil, connexion).
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 28), this.radius = 28});
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: inkGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.brand.withValues(alpha: 0.45), AppColors.brand.withValues(alpha: 0)]),
              ),
            ),
          ),
          const Positioned(
            right: -24,
            bottom: -34,
            child: Opacity(opacity: 0.07, child: LogoMark(size: 150, withBackground: false, color: Colors.white)),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// En-tête des formulaires : pictogramme, titre et explication.
class FormIntro extends StatelessWidget {
  const FormIntro({super.key, required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Tone.brand.softBg(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(gradient: brandGradient, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(text, style: t.bodyMedium),
          ]),
        ),
      ]),
    );
  }
}

/// Liste défilante standard des écrans de l'appli, avec tirer-pour-rafraîchir.
class RefreshableList extends StatelessWidget {
  const RefreshableList({super.key, required this.onRefresh, required this.children});
  final Future<void> Function() onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
        children: children,
      ),
    );
  }
}

/// Ligne « libellé — valeur » des écrans de détail.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({super.key, required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: t.bodySmall?.color), const SizedBox(width: AppSpacing.md)],
          Expanded(child: Text(label, style: t.bodyMedium)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(value.isEmpty ? '—' : value, style: t.titleSmall, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

/// Carte d'action de l'accueil (Scanner, Mes tickets...).
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tone = Tone.brand,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Tone tone;

  /// Action principale du rôle : mise en avant en couleur pleine.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final fg = primary ? Colors.white : null;
    return Card(
      color: primary ? AppColors.brand : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary ? Colors.white.withValues(alpha: 0.18) : tone.softBg(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: primary ? Colors.white : tone.fg),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.titleMedium?.copyWith(color: fg)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: t.bodySmall?.copyWith(color: primary ? Colors.white70 : null)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: primary ? Colors.white : t.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte d'un ticket dans les listes (chauffeur et agent).
class TicketTile extends StatelessWidget {
  const TicketTile({super.key, required this.ticket, required this.onTap, this.showBeneficiaire = false});
  final Map<String, dynamic> ticket;
  final VoidCallback onTap;
  final bool showBeneficiaire;

  @override
  Widget build(BuildContext context) {
    return TicketCard(
      data: TicketData.fromMap(ticket),
      compact: true,
      showBeneficiaire: showBeneficiaire,
      onTap: onTap,
    );
  }
}

/// Icône cloche avec badge du nombre de notifications non lues.
class NotificationBadgeIcon extends StatelessWidget {
  const NotificationBadgeIcon({super.key, this.selected = false});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationStore.unread,
      builder: (_, count, __) => Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.brand,
        child: Icon(selected ? Icons.notifications_rounded : Icons.notifications_outlined),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  final ok = await confirmDialog(
    context,
    title: 'Se déconnecter ?',
    message: 'Vous devrez saisir à nouveau vos identifiants.',
    confirmLabel: 'Déconnexion',
  );
  if (!ok || !context.mounted) return;
  await Session.clear();
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (_) => false);
}
