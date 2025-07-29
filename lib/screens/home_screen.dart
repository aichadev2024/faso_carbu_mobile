import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faso_carbu_mobile/services/api_service.dart';
import 'package:logger/logger.dart';


var logger = Logger();

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String userRole;
  final String token;
  final String nom;
  final String prenom;

  const HomeScreen({
    super.key,
    required this.userEmail,
    required this.userRole,
    required this.token,
    required this.nom,
    required this.prenom,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
    ApiService.syncCarburants();
  }


  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      logger.i("🧾 userId depuis SharedPreferences: $userId");
    });
  }

  String formatRole(String role) {
    switch (role) {
      case 'ROLE_GESTIONNAIRE':
        return 'Gestionnaire';
      case 'ROLE_CHAUFFEUR':
        return 'Chauffeur';
      case 'ROLE_AGENT_STATION':
        return 'Agent Station';
      default:
        return role;
    }
  }

  void navigate(BuildContext context, String routeName) {
    Navigator.pushNamed(
      context,
      routeName,
      arguments: {
        'userEmail': widget.userEmail,
        'userRole': widget.userRole,
        'token': widget.token,
        'nom': widget.nom,
        'prenom': widget.prenom,
        'userId': userId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = widget.userRole == 'ROLE_CHAUFFEUR'
        ? [Colors.green.shade200, Colors.green.shade50]
        : widget.userRole == 'ROLE_GESTIONNAIRE'
            ? [Colors.blue.shade200, Colors.blue.shade50]
            : [Colors.orange.shade200, Colors.orange.shade50];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FasoCarbu - Accueil'),
        backgroundColor: const Color.fromARGB(255, 76, 168, 175),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green[300],
                      child: const Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenue dans FasoCarbu 👋',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.userEmail,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          Text(
                            'Rôle : ${formatRole(widget.userRole)}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          if (userId != null)
                            Text(
                              'ID utilisateur : $userId',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                children: [
                  if (widget.userRole == 'ROLE_GESTIONNAIRE') ...[
                    _buildTile(
                      icon: Icons.qr_code,
                      label: 'Valider les demandes',
                      onTap: () => navigate(context, '/valider-demandes'),
                    ),
                    _buildTile(
                      icon: Icons.bar_chart,
                      label: 'Statistiques',
                      onTap: () => navigate(context, '/stats'),
                    ),
                  ],
                  if (widget.userRole == 'ROLE_CHAUFFEUR') ...[
                    _buildTile(
                      icon: Icons.request_page,
                      label: 'Demander un ticket',
                      onTap: () => navigate(context, '/ticket-request'),
                    ),
                    _buildTile(
                      icon: Icons.list_alt,
                      label: 'Historique des tickets',
                      onTap: () => navigate(context, '/ticket-list'),
                    ),
                    _buildTile(
                      icon: Icons.offline_pin,
                      label:'Demandes locales',
                      onTap:()=> navigate(context,'/local-requests',)
                    ),
                    
                  ],
                  if (widget.userRole == 'ROLE_AGENT_STATION') ...[
                    _buildTile(
                      icon: Icons.qr_code_scanner,
                      label: 'Scanner un QR Code',
                      onTap: () => navigate(context, '/scan-qr'),
                    ),
                    _buildTile(
                      icon: Icons.history,
                      label: 'Historique des validations',
                      onTap: () => navigate(context, '/ticket-list'),
                    ),
                  ],
                  _buildTile(
                    icon: Icons.local_gas_station,
                    label: 'Voir les Carburants',
                    onTap: () => navigate(context, '/carburants'),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.green),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
