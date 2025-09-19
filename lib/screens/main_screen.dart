import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final String userId; // ⚡ Champ obligatoire pour le backend

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
        userId: widget.userId, // ✅ UUID correct
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/home.svg",
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/home.svg",
              height: 28,
              colorFilter: ColorFilter.mode(
                Colors.red.shade700,
                BlendMode.srcIn,
              ),
            ),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/profile.svg",
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/profile.svg",
              height: 28,
              colorFilter: ColorFilter.mode(
                Colors.red.shade700,
                BlendMode.srcIn,
              ),
            ),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/notif.svg",
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/notif.svg",
              height: 28,
              colorFilter: ColorFilter.mode(
                Colors.red.shade700,
                BlendMode.srcIn,
              ),
            ),
            label: "Notifications",
          ),
        ],
      ),
    );
  }
}
