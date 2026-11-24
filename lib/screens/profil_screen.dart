import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/api.dart';
import '../core/config/app_config.dart';
import '../core/session.dart';
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

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final entreprise = _user['entreprise'] is Map ? (_user['entreprise'] as Map)['nom']?.toString() : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: RefreshableList(
        onRefresh: _load,
        children: [
          Center(
            child: Stack(children: [
              InitialsAvatar(name: Session.fullName, size: 96, imageUrl: _photoUrl),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _uploading ? null : _changePhoto,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _uploading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.photo_camera_outlined, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(child: Text(Session.fullName, style: t.headlineSmall)),
          const SizedBox(height: AppSpacing.xs),
          Center(child: StatusBadge(label: Session.roleLabel, tone: Tone.brand)),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Column(children: [
                KeyValueRow(icon: Icons.mail_outline_rounded, label: 'Email', value: Session.email),
                KeyValueRow(icon: Icons.phone_outlined, label: 'Téléphone', value: '${_user['telephone'] ?? ''}'),
                KeyValueRow(icon: Icons.business_outlined, label: 'Entreprise', value: entreprise ?? ''),
              ]),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.lock_reset_rounded),
                title: const Text('Changer le mot de passe'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: Icon(Icons.logout_rounded, color: Tone.danger.fg),
                title: Text('Se déconnecter', style: TextStyle(color: Tone.danger.fg)),
                onTap: () => logout(context),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
