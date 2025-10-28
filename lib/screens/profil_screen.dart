import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faso_carbu_mobile/screens/change_password_screen.dart';

class ProfilScreen extends StatefulWidget {
  final String userEmail;
  final String userRole;
  final String token;
  final String nom;
  final String prenom;
  final String userId;
  final VoidCallback onLogout;

  const ProfilScreen({
    super.key,
    required this.userEmail,
    required this.userRole,
    required this.token,
    required this.nom,
    required this.prenom,
    required this.userId,
    required this.onLogout,
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  File? _profileImage;
  String? _photoUrl;
  bool _isUploading = false;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadLocalPhoto();
    _fetchUserPhotoWithRetry();
  }

  Future<void> _loadLocalPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('photoProfil_${widget.userId}');
    if (!mounted) return;
    setState(() => _photoUrl = savedUrl);
  }

  Future<void> _saveLocalPhoto(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('photoProfil_${widget.userId}', url);
  }

  Future<void> _fetchUserPhotoWithRetry({
    int retries = 3,
    int delaySeconds = 3,
  }) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final response = await http.get(
          Uri.parse(
            "https://faso-carbu-backend-2.onrender.com/api/utilisateurs/${widget.userId}",
          ),
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final url = data['photoProfil'] ?? data['photo_profil'];

          if (url != null &&
              url.isNotEmpty &&
              Uri.tryParse(url)?.isAbsolute == true) {
            if (!mounted) return;
            await _saveLocalPhoto(url);
            setState(() => _photoUrl = url);
          }
          break;
        } else {
          debugPrint("Erreur serveur: ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Tentative ${attempt + 1} échouée: $e");
        if (attempt < retries - 1) {
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      }
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _profileImage = File(pickedFile.path);
        _isUploading = true;
      });
      await _uploadPhoto(File(pickedFile.path));
    }
  }

  Future<void> _uploadPhoto(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "https://faso-carbu-backend-2.onrender.com/api/utilisateurs/${widget.userId}/upload-photo",
        ),
      );
      request.headers['Authorization'] = "Bearer ${widget.token}";
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResp = json.decode(respStr);
        final photoUrl = jsonResp['photoProfil'] ?? jsonResp['photo_profil'];

        if (photoUrl != null && photoUrl.isNotEmpty) {
          if (!mounted) return;
          await _saveLocalPhoto(photoUrl);
          setState(() {
            _photoUrl = photoUrl;
            _profileImage = null;
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Photo mise à jour avec succès !")),
          );
        }
      } else {
        if (!mounted) return;
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur upload photo : ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Erreur upload photo : $e")));
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Photo de profil",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Caméra"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galerie"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'ROLE_CHAUFFEUR':
        return 'Chauffeur';
      case 'ROLE_GESTIONNAIRE':
        return 'Gestionnaire';
      case 'ROLE_AGENT_STATION':
        return 'Agent de station';
      case 'ROLE_ADMIN_STATION':
        return 'Admin de station';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: screenHeight * 0.3,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 10,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.08,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _showPhotoOptions,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white,
                                child: ClipOval(
                                  child: _isUploading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.red,
                                          ),
                                        )
                                      : (_profileImage != null
                                            ? Image.file(
                                                _profileImage!,
                                                fit: BoxFit.cover,
                                                width: 110,
                                                height: 110,
                                              )
                                            : (_photoUrl != null
                                                  ? Image.network(
                                                      _photoUrl!,
                                                      fit: BoxFit.cover,
                                                      width: 110,
                                                      height: 110,
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Image.asset(
                                                            'assets/images/default_avatar.png',
                                                            fit: BoxFit.cover,
                                                            width: 110,
                                                            height: 110,
                                                          ),
                                                    )
                                                  : Image.asset(
                                                      'assets/images/default_avatar.png',
                                                      fit: BoxFit.cover,
                                                      width: 110,
                                                      height: 110,
                                                    ))),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${widget.nom} ${widget.prenom}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatRole(widget.userRole),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.redAccent),
                      title: Text(widget.userEmail),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(
                        Icons.security,
                        color: Colors.redAccent,
                      ),
                      title: const Text("Changer le mot de passe"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChangePasswordScreen(token: widget.token),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: widget.onLogout,
                      label: const Text(
                        "Se déconnecter",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
