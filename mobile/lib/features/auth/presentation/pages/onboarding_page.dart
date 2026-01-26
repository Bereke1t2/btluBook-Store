import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ethio_book_store/core/const/ui_const.dart';
import 'package:ethio_book_store/core/const/app_typography.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/animated_button.dart';

/// Onboarding page shown to new users.
/// Displays 3-4 beautifully animated screens explaining the app.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  /// Check if onboarding has been completed
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final PageController _pageController;
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.menu_book_rounded,
      title: 'Discover Books',
      description: 'Browse thousands of books across various genres. From fiction to academic, find your next favorite read.',
      gradient: [const Color(0xFFF2C94C), const Color(0xFFD4A373)],
    ),
    _OnboardingData(
      icon: Icons.cloud_download_rounded,
      title: 'Download & Read Offline',
      description: 'Download books to read anytime, anywhere. Your library is always with you, even without internet.',
      gradient: [const Color(0xFFA1E3B5), const Color(0xFF4CAF50)],
    ),
    _OnboardingData(
      icon: Icons.psychology_rounded,
      title: 'AI Book Assistant',
      description: 'Chat with our AI about any book. Get summaries, explanations, and even take quizzes to test your knowledge.',
      gradient: [const Color(0xFF64B5F6), const Color(0xFF2196F3)],
    ),
    _OnboardingData(
      icon: Icons.share_rounded,
      title: 'Share & Contribute',
      description: 'Upload your own books to share with the community. Build your reputation and earn points!',
      gradient: [const Color(0xFFE57373), const Color(0xFFEF5350)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: UiConst.durationBackground,
    )..repeat(reverse: true);
    
    _pageController = PageController();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: UiConst.durationMedium,
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _skip() {
    _complete();
  }

  Future<void> _complete() async {
    await OnboardingPage.markCompleted();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_bgController.value);
          final begin = Alignment.lerp(Alignment.bottomLeft, Alignment.topRight, t)!;
          final end = Alignment.lerp(Alignment.topRight, Alignment.bottomLeft, t)!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: UiConst.gradientBackground,
                stops: UiConst.gradientStops,
              ),
            ),
            child: Stack(
              children: [
                // Animated glow circles
                _AnimatedGlowCircle(
                  controller: _bgController,
                  size: 300,
                  color: _pages[_currentPage].gradient[0],
                  left: -100,
                  top: -80,
                ),
                _AnimatedGlowCircle(
                  controller: _bgController,
                  size: 350,
                  color: _pages[_currentPage].gradient[1],
                  right: -120,
                  bottom: -100,
                  reverse: true,
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // Skip button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: _skip,
                            child: Text(
                              'Skip',
                              style: AppTypography.labelLarge.copyWith(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),

                      // Page content
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemCount: _pages.length,
                          itemBuilder: (context, index) {
                            return _OnboardingContent(
                              data: _pages[index],
                              isActive: index == _currentPage,
                            );
                          },
                        ),
                      ),

                      // Page indicators and button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: Column(
                          children: [
                            // Dot indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_pages.length, (index) {
                                final isActive = index == _currentPage;
                                return AnimatedContainer(
                                  duration: UiConst.durationFast,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: isActive ? 32 : 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: isActive
                                        ? LinearGradient(colors: _pages[_currentPage].gradient)
                                        : null,
                                    color: isActive ? null : Colors.white24,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 32),

                            // Button
                            SizedBox(
                              width: double.infinity,
                              child: AnimatedButton(
                                label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                                icon: _currentPage == _pages.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : null,
                                isPrimary: true,
                                onTap: _nextPage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Data model for onboarding page
class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

/// Single onboarding page content
class _OnboardingContent extends StatelessWidget {
  final _OnboardingData data;
  final bool isActive;

  const _OnboardingContent({
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: UiConst.durationMedium,
      opacity: isActive ? 1.0 : 0.5,
      child: AnimatedScale(
        duration: UiConst.durationMedium,
        scale: isActive ? 1.0 : 0.9,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon in gradient circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: data.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.gradient[0].withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  data.icon,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.white, data.gradient[0]],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  data.title,
                  style: AppTypography.displayMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Description
              GlassContainer(
                borderRadius: UiConst.radiusLarge,
                blurSigma: UiConst.blurMedium,
                color: UiConst.glassFill,
                borderColor: UiConst.glassBorder,
                padding: const EdgeInsets.all(20),
                child: Text(
                  data.description,
                  style: AppTypography.bodyLarge.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated glow circle that moves with the background
class _AnimatedGlowCircle extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final Color color;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final bool reverse;

  const _AnimatedGlowCircle({
    required this.controller,
    required this.size,
    required this.color,
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(controller.value);
        final offset = (reverse ? -1 : 1) * (t - 0.5) * 30;
        
        return Positioned(
          left: left != null ? left! + offset : null,
          right: right != null ? right! - offset : null,
          top: top != null ? top! + offset : null,
          bottom: bottom != null ? bottom! - offset : null,
          child: child!,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
          ),
        ),
      ),
    );
  }
}
