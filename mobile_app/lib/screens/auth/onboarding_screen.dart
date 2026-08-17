import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/contact_picker_service.dart';
import '../../providers/emergency_contacts_provider.dart';
import 'login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'ওষুধ খেতে আর ভুলবেন না',
      'subtitle': 'সহজ রিমাইন্ডার এবং ভয়েস নোটিফিকেশনের মাধ্যমে সঠিক সময়ে ওষুধ গ্রহণ করুন।',
      'icon': '⏰',
    },
    {
      'title': 'পরিবারকে জানান আপনি সুস্থ আছেন',
      'subtitle': 'আপনার পরিবারের সদস্যরা আপনার ওষুধ খাওয়ার আপডেট জানতে পারবেন।',
      'icon': '👨👩👧',
    },
    {
      'title': 'জরুরি SOS ও স্বজন সাপোর্ট',
      'subtitle': 'জরুরি অবস্থায় ১-ক্লিকে স্বজন এবং হেল্পলাইনে সরাসরি কল করুন।',
      'icon': '🆘',
    },
  ];

  void _finishOnboarding() async {
    await StorageService.setOnboardingComplete();
    
    // Interactive User Choice for Importing Emergency Contacts
    if (mounted) {
      final userSelectedContacts =
          await ContactPickerService.showInteractiveContactPicker(context);
      if (userSelectedContacts.isNotEmpty) {
        await ref
            .read(emergencyContactsProvider.notifier)
            .setContacts(userSelectedContacts);
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, idx) {
                  final item = _pages[idx];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item['icon']!, style: const TextStyle(fontSize: 90)),
                        const SizedBox(height: 40),
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (idx) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == idx ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == idx ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _finishOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _currentPage == _pages.length - 1 ? 'শুরু করুন' : 'পরবর্তী',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
