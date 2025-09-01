import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Bienvenue sur FasoCarbu",
      "description": "Votre solution moderne pour gérer vos tickets carburant.",
      "image": "assets/images/station_fuel.SVG",
    },
    {
      "title": "Chauffeurs & Agents",
      "description": "Un suivi simple et rapide pour chaque utilisateur.",
      "image": "assets/images/driver.SVG",
    },
    {
      "title": "Stations de service",
      "description": "Scannez et validez vos tickets en toute sécurité.",
      "image": "assets/images/agent.SVG",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return AnimatedOpacity(
                  opacity: _currentPage == index ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSlide(
                        offset: _currentPage == index
                            ? Offset.zero
                            : const Offset(0.2, 0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        child: SvgPicture.asset(
                          onboardingData[index]["image"]!,
                          height: 250,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        onboardingData[index]["title"]!,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          onboardingData[index]["description"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 🔹 Indicateurs de page
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 10,
                width: _currentPage == index ? 25 : 10,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.red
                      : Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // 🔹 Bouton animé
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {});
                },
                onTapUp: (_) {
                  if (_currentPage == onboardingData.length - 1) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const _FadeSlideTransition(toPage: '/login'),
                        transitionDuration: const Duration(milliseconds: 700),
                      ),
                    );
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? "Commencer"
                          : "Suivant",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Transition personnalisée (fade + slide)
class _FadeSlideTransition extends StatelessWidget {
  final String toPage;
  const _FadeSlideTransition({required this.toPage});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          pageBuilder: (_, animation, _) {
            final Widget page;
            switch (toPage) {
              case '/login':
                page = const Placeholder(
                  fallbackHeight: 100,
                  fallbackWidth: 100,
                ); // ⚠️ remplace par LoginScreen
                break;
              default:
                page = const Scaffold(
                  body: Center(child: Text("Page non trouvée")),
                );
            }
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: page),
            );
          },
          transitionDuration: const Duration(milliseconds: 700),
        );
      },
    );
  }
}
