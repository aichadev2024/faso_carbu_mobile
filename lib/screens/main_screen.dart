import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profil_screen.dart';
import 'notification_screen.dart';

class MainScreen extends StatefulWidget {
  final String email;
  final String role;
  final String token;
  final String nom;
  final String prenom;

  const MainScreen({
    super.key,
    required this.email,
    required this.role,
    required this.token,
    required this.nom,
    required this.prenom,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        userEmail: widget.email,
        userRole: widget.role,
        token: widget.token,
        nom: widget.nom,
        prenom: widget.prenom,
      ),
      ProfilScreen(
        userEmail: widget.email,
        userRole: widget.role,
        token: widget.token,
        nom: widget.nom,
        prenom: widget.prenom,
        onLogout: _handleLogout,
      ),
      const NotificationScreen(),
    ];
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onWillPop() async {
    // Afficher une confirmation de déconnexion
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Voulez-vous vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Oui'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await _onWillPop();
        if (shouldLogout) {
          _handleLogout(); // Déconnecte et revient à /login
        }
        return false; // Empêche le retour automatique
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          ],
        ),
      ),
    );
  }
}