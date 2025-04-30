import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'location_permission_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Selamat Datang',
      'desc': 'Temukan bengkel terdekat dengan mudah dan cepat!',
      'image': 'assets/onboarding_one.svg',
    },
    {
      'title': 'Aktifkan Lokasi',
      'desc':
          'Silakan aktifkan lokasi terlebih dahulu untuk melihat bengkel di sekitar Anda.',
      'image': 'assets/onboarding_two.svg',
    },
    {
      'title': 'Bengkel Ditemukan',
      'desc': 'Kami akan menampilkan daftar bengkel terdekat secara otomatis.',
      'image': 'assets/onboarding_three.svg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        page['image']!,
                        height: 250,
                      ),
                      // Image.asset(page['image']!, height: 250),
                      const SizedBox(height: 40),
                      Text(
                        page['title']!,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        page['desc']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: _pages.length,
            effect: WormEffect(dotHeight: 10, dotWidth: 10),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                // if (_currentIndex == _pages.length - 1) {
                //   Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
                //   );
                // } else {
                //   _controller.nextPage(
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut,
                //   );
                // }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child:
                  Text(_currentIndex == _pages.length - 1 ? "Mulai" : "Lanjut"),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
