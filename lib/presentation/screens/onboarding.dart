import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/onboarding_model.dart';
import '../widgets/onboarding_page.dart';
import 'home_screen.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final list = OnboardingModel.onboardingList;
    return Scaffold(
      backgroundColor: AppColors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return OnboardingPage(
            model: list[index],
            index: index,
            total: list.length,
            onNext: () {
              if (index < list.length - 1) {
                _nextPage();
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(key: HomeScreen.homeKey)),
                );
              }
            },
            onBack: () => _previousPage(),
          );
        },
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
