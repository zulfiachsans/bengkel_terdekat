import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: SvgPicture.asset(
                            data['image']!,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          data['title']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(data['desc']!, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: const WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex > 0)
                    ElevatedButton(
                      onPressed: _prevPage,
                      child: const Text('Sebelumnya'),
                    )
                  else
                    const SizedBox(width: 100), // biar rata tengah
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex == _pages.length - 1) {
                        // TODO: Navigasi ke halaman utama
                      } else {
                        _nextPage();
                      }
                    },
                    child: Text(_currentIndex == _pages.length - 1
                        ? 'Mulai'
                        : 'Lanjut'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
