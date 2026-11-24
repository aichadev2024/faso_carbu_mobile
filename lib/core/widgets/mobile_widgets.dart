import 'package:flutter/material.dart';

import '../notification_store.dart';
import '../session.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

/// Logo FasoCarbu : pictogramme + nom.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 34, this.onDark = false, this.showName = true});
  final double size;
  final bool onDark;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(size * 0.28)),
          child: Icon(Icons.local_gas_station_rounded, color: Colors.white, size: size * 0.58),
        ),
        if (showName) ...[
          SizedBox(width: size * 0.32),
          Text(
            'FasoCarbu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: size * 0.56,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: onDark ? Colors.white : null,
                ),
          ),
        ],
      ],
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
    final t = Theme.of(context).textTheme;
    final qte = double.tryParse('${ticket['quantite'] ?? 0}') ?? 0;
    final somme = double.tryParse('${ticket['somme'] ?? ticket['montant'] ?? 0}') ?? 0;
    final date = DateTime.tryParse('${ticket['dateValidation'] ?? ticket['dateEmission'] ?? ''}');
    final beneficiaire = '${ticket['utilisateurPrenom'] ?? ''} ${ticket['utilisateurNom'] ?? ''}'.trim();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Ticket #${ticket['id'] ?? '—'}', style: t.labelMedium),
                const Spacer(),
                StatusBadge.fromStatus(ticket['statut']?.toString()),
              ]),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${formatNumber(qte)} L · ${ticket['carburantNom'] ?? 'Carburant'}', style: t.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (showBeneficiaire && beneficiaire.isNotEmpty) beneficiaire,
                            if ((ticket['stationNom'] ?? '').toString().isNotEmpty) ticket['stationNom'].toString(),
                            formatDate(date),
                          ].join(' · '),
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text('${formatNumber(somme)} F', style: t.titleMedium),
                ],
              ),
            ],
          ),
        ),
      ),
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
