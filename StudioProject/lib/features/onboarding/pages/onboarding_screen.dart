import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/pages/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<OnboardingData> pages = [
    OnboardingData(
      image: 'assets/images/onboarding_1.png',
      text: 'Pesan kopi favorit kamu lebih mudah',
    ),
    OnboardingData(
      image: 'assets/images/onboarding_2.png',
      text: 'Semua menu tersedia dalam genggaman',
    ),
    OnboardingData(
      image: 'assets/images/onboarding_3.png',
      text: 'Nikmati segelas kopi sesuai dengan selera anda dari Bakoel Coffee',
    ),
  ];

  Future<void> handleFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
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
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        pages[index].image,
                        width: 230,
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 600),
                          opacity: currentPage == index ? 1 : 0,
                          child: Text(
                            pages[index].text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Helvetica",
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // DOT INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  width: currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Colors.black87
                        : Colors.black38,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BUTTON AREA
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: currentPage == 2

              // ✅ SLIDE TERAKHIR - BUTTON LOGIN
                  ? TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0.5, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: SizedBox(
                      width: 220,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: handleFinish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontFamily: "Helvetica",
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )

              // ✅ SLIDE 1 & 2 - PANAH TENGAH
                  : Center(
                child: GestureDetector(
                  onTap: nextPage,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String text;

  OnboardingData({
    required this.image,
    required this.text,
  });
}