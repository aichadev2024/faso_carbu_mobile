import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/api.dart';
import '../core/config/app_config.dart';
import '../core/session.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';
import 'change_password_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Map<String, dynamic> _user = {};
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (Session.userId.isEmpty) return;
    try {
      final data = await Api.get('/utilisateurs/${Session.userId}');
      if (data is Map && mounted) setState(() => _user = Map<String, dynamic>.from(data));
    } on ApiException catch (_) {
      // Le profil s'affiche quand même avec les infos de session.
    }
  }

  String? get _photoUrl {
    final p = _user['photoProfil']?.toString();
    if (p == null || p.isEmpty) return null;
    return p.startsWith('http') ? p : '${AppConfig.backendUrl}$p';
  }

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final req = http.MultipartRequest('POST', Uri.parse('${AppConfig.apiUrl}/utilisateurs/${Session.userId}/upload-photo'))
        ..headers['Authorization'] = 'Bearer ${Session.token}'
        ..files.add(http.MultipartFile.fromBytes('file', await picked.readAsBytes(), filename: picked.name));
      final res = await req.send();
      if (res.statusCode != 200) throw Exception();
      final data = jsonDecode(await res.stream.bytesToString());
      if (!mounted) return;
      setState(() => _user = {..._user, 'photoProfil': '${data['photoProfil']}?t=${DateTime.now().millisecondsSinceEpoch}'});
      showAppSnack(context, 'Photo mise à jour.', tone: Tone.success);
    } catch (_) {
      if (mounted) showAppSnack(context, 'Envoi de la photo impossible.', tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Widget _tile(IconData icon, String title, {String? subtitle, Tone tone = Tone.neutral, VoidCallback? onTap, bool danger = false}) {
    final t = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: tone.softBg(context), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Icon(icon, size: 19, color: tone.fg),
      ),
      title: Text(title, style: t.titleSmall?.copyWith(color: danger ? Tone.danger.fg : null)),
      subtitle: subtitle == null ? null : Text(subtitle, style: t.bodySmall),
      trailing: danger ? null : Icon(Icons.chevron_right_rounded, color: t.bodySmall?.color),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final entreprise = _user['entreprise'] is Map ? (_user['entreprise'] as Map)['nom']?.toString() : null;
    Widget section(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, AppSpacing.xl, 4, AppSpacing.sm),
      child: Text(text.toUpperCase(), style: t.labelSmall?.copyWith(letterSpacing: 1.1)),
    );
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            BrandHeader(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 20, 20, 28),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                          ),
                          child: InitialsAvatar(name: Session.fullName, size: 92, imageUrl: _photoUrl),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _uploading ? null : _changePhoto,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: _uploading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.photo_camera_outlined, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      Session.fullName,
                      style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(999)),
                      child: Text(Session.roleLabel, style: t.labelMedium?.copyWith(color: const Color(0xFFFDBA74))),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  section('Informations'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                      child: Column(
                        children: [
                          KeyValueRow(icon: Icons.mail_outline_rounded, label: 'Email', value: Session.email),
                          const Divider(),
                          KeyValueRow(icon: Icons.phone_outlined, label: 'Téléphone', value: '${_user['telephone'] ?? ''}'),
                          const Divider(),
                          KeyValueRow(icon: Icons.business_outlined, label: 'Entreprise', value: entreprise ?? ''),
                        ],
                      ),
                    ),
                  ),
                  section('Compte'),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _tile(
                          Icons.lock_reset_rounded,
                          'Changer le mot de passe',
                          subtitle: 'Conseillé régulièrement',
                          tone: Tone.brand,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                        ),
                        const Divider(indent: 70),
                        _tile(Icons.logout_rounded, 'Se déconnecter', tone: Tone.danger, danger: true, onTap: () => logout(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(child: Opacity(opacity: 0.6, child: BrandMark(size: 22))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
