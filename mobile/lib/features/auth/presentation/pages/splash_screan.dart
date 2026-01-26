import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/GlowCircle.dart';
import '../../../../core/const/ui_const.dart';
import '../../../../core/const/app_typography.dart';

/// Enhanced Splash Screen with:
/// - Animated logo with scale/fade effects
/// - Shimmer effect on brand text
/// - Smooth transitions
class SplashScrean extends StatefulWidget {
  const SplashScrean({super.key});

  @override
  State<SplashScrean> createState() => _SplashScreanState();
}

class _SplashScreanState extends State<SplashScrean>
    with TickerProviderStateMixin {
  // Background animation controller
  late final AnimationController _bgController;
  
  // Logo animation controller
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoRotation;
  
  // Content animation controller (text, loading)
  late final AnimationController _contentController;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  
  // Shimmer animation controller
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    
    // Background animation (slow continuous)
    _bgController = AnimationController(
      vsync: this,
      duration: UiConst.durationBackground,
    )..repeat(reverse: true);

    // Logo animation (entrance)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    _logoRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Content animation (delayed entrance)
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );
    
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Shimmer effect controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    _contentController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _contentController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
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
                  // Animated glowing blobs
                  _AnimatedGlow(
                    animation: _bgController,
                    left: -60,
                    top: -40,
                    size: 260,
                    color: UiConst.glowAmber,
                    offsetMultiplier: 20,
                  ),
                  _AnimatedGlow(
                    animation: _bgController,
                    right: -80,
                    bottom: -60,
                    size: 320,
                    color: UiConst.glowSage,
                    offsetMultiplier: -25,
                  ),
                  _AnimatedGlow(
                    animation: _bgController,
                    right: -20,
                    top: 80,
                    size: 180,
                    color: UiConst.glowParchment,
                    offsetMultiplier: 15,
                  ),

                  // Main content
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(UiConst.radiusXLarge),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: UiConst.blurMedium,
                          sigmaY: UiConst.blurMedium,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 36,
                          ),
                          decoration: BoxDecoration(
                            color: UiConst.glassFill,
                            borderRadius: BorderRadius.circular(UiConst.radiusXLarge),
                            border: Border.all(color: UiConst.glassBorder),
                            boxShadow: UiConst.cardShadow,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated Logo
                              AnimatedBuilder(
                                animation: _logoController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _logoScale.value,
                                    child: Transform.rotate(
                                      angle: _logoRotation.value,
                                      child: Opacity(
                                        opacity: _logoOpacity.value,
                                        child: _buildLogo(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Shimmer Brand Text
                              AnimatedBuilder(
                                animation: _contentController,
                                builder: (context, child) {
                                  return SlideTransition(
                                    position: _contentSlide,
                                    child: FadeTransition(
                                      opacity: _contentOpacity,
                                      child: _buildShimmerText(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              
                              // Subtitle
                              FadeTransition(
                                opacity: _contentOpacity,
                                child: SlideTransition(
                                  position: _contentSlide,
                                  child: Text(
                                    'Loading your next great read...',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Animated Loading Indicator
                              FadeTransition(
                                opacity: _contentOpacity,
                                child: _buildLoadingIndicator(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: UiConst.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: UiConst.glowShadow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing ring
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              final scale = 1.0 + (_shimmerController.value * 0.15);
              final opacity = 1.0 - _shimmerController.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: UiConst.amber.withOpacity(opacity * 0.5),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          // Icon
          const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerText() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: UiConst.amber,
      period: const Duration(milliseconds: 2000),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: UiConst.brandTextGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Text(
          'btluBook Store',
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _shimmerController.value * 6.28,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 3,
                    ),
                  ),
                  child: CustomPaint(
                    painter: _ArcPainter(
                      progress: _shimmerController.value,
                      color: UiConst.amber,
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner pulsing dot
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              final scale = 0.6 + (0.4 * (1 - (_shimmerController.value - 0.5).abs() * 2));
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: UiConst.amber,
                    boxShadow: [
                      BoxShadow(
                        color: UiConst.amber.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Animated glow circle that moves subtly
class _AnimatedGlow extends StatelessWidget {
  final Animation<double> animation;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;
  final Color color;
  final double offsetMultiplier;

  const _AnimatedGlow({
    required this.animation,
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.color,
    required this.offsetMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final offset = animation.value * offsetMultiplier;
        return Positioned(
          left: left != null ? left! + offset : null,
          right: right != null ? right! + offset : null,
          top: top != null ? top! + offset : null,
          bottom: bottom != null ? bottom! - offset : null,
          child: GlowCircle(size: size, color: color),
        );
      },
    );
  }
}

/// Custom painter for the arc loading indicator
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -1.57; // -90 degrees
    const sweepAngle = 2.0; // About 115 degrees

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}