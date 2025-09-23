import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profil_screen.dart';
import 'notification_screen.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class MainScreen extends StatefulWidget {
  final String email;
  final String role;
  final String token;
  final String nom;
  final String prenom;
  final String userId;

  const MainScreen({
    super.key,
    required this.email,
    required this.role,
    required this.token,
    required this.nom,
    required this.prenom,
    required this.userId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    logger.i("🔑 Token courant : ${widget.token}");

    _screens = [
      HomeScreen(
        userEmail: widget.email,
        userRole: widget.role,
        token: widget.token,
        nom: widget.nom,
        prenom: widget.prenom,
        userId: widget.userId,
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
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmation"),
            content: const Text("Voulez-vous vraiment quitter l'application ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Non"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Oui"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 🔹 Intercepte la sortie
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.red.shade700,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24, color: Colors.grey),
              activeIcon: Icon(Icons.home, size: 28, color: Colors.red),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 24, color: Colors.grey),
              activeIcon: Icon(Icons.person, size: 28, color: Colors.red),
              label: "Profil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, size: 24, color: Colors.grey),
              activeIcon: Icon(
                Icons.notifications,
                size: 28,
                color: Colors.red,
              ),
              label: "Notifications",
            ),
          ],
        ),
      ),
    );
  }
}
