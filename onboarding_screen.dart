import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: '내 손 안의 옷장',
      subtitle: '',
    ),
    OnboardingContent(
      title: '나의 옷장',
      subtitle: '자신의 옷을 디지털 코디네이터와 함께',
    ),
    OnboardingContent(
      title: 'AI 피팅',
      subtitle: '가상 피팅으로 미리보고\n맞춤을 선택하세요',
    ),
    OnboardingContent(
      title: '의류상터',
      subtitle: '같은 옷도 새롭게\n새로운 스타일링',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentPage < _contents.length - 1) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
        );
      } else {
        _currentPage = 0;
        _pageController.jumpToPage(_currentPage); // 첫 페이지로 즉시 이동
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer 취소
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.pink[50],
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(content: _contents[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  // 로그인 화면으로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '지금 시작하기',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String subtitle;

  OnboardingContent({
    required this.title,
    required this.subtitle,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 100, color: Colors.white), // 카트 아이콘
          const SizedBox(height: 20),
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (content.subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
