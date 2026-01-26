import 'dart:ui';
import 'package:ethio_book_store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/const/ui_const.dart';
import '../../../../core/const/app_typography.dart';
import '../widgets/GlowCircle.dart';

/// Enhanced Login Page with:
/// - Social login buttons (UI only)
/// - Smooth page entrance animations
/// - Improved glassmorphism design
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Background animation
  late final AnimationController _bgController;
  
  // Form entrance animation
  late final AnimationController _entranceController;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;
  
  // Form fields animation
  late final AnimationController _fieldsController;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    
    // Background animation
    _bgController = AnimationController(
      vsync: this,
      duration: UiConst.durationBackground,
    )..repeat(reverse: true);
    
    // Card entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _cardScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Fields stagger animation
    _fieldsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fieldsController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    _fieldsController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (!mounted) return;
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
            ),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login coming soon!'),
        backgroundColor: UiConst.slate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.10),
      hintStyle: AppTypography.hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        borderSide: const BorderSide(color: UiConst.amber, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        borderSide: const BorderSide(color: UiConst.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        borderSide: const BorderSide(color: UiConst.error),
      ),
    );
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

          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                Navigator.of(context).pushReplacementNamed('/home');
              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: UiConst.error,
                  ),
                );
              }
            },
            child: Container(
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
                  const Positioned(
                    left: -60,
                    top: -40,
                    child: GlowCircle(size: 260, color: UiConst.glowAmber),
                  ),
                  const Positioned(
                    right: -80,
                    bottom: -60,
                    child: GlowCircle(size: 320, color: UiConst.glowSage),
                  ),
                  const Positioned(
                    right: -20,
                    top: 80,
                    child: GlowCircle(size: 180, color: UiConst.glowParchment),
                  ),
                  
                  // Main card with animations
                  Center(
                    child: AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _cardScale.value,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: FadeTransition(
                              opacity: _cardOpacity,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _buildLoginCard(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiConst.radiusXLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: UiConst.blurMedium,
          sigmaY: UiConst.blurMedium,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 26),
          decoration: BoxDecoration(
            color: UiConst.glassFill,
            borderRadius: BorderRadius.circular(UiConst.radiusXLarge),
            border: Border.all(color: UiConst.glassBorder),
            boxShadow: UiConst.cardShadow,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 14),
                  
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: UiConst.brandTextGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue reading',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Social Login Buttons
                  _buildSocialLoginSection(),
                  const SizedBox(height: 20),
                  
                  // Divider
                  _buildDivider(),
                  const SizedBox(height: 20),
                  
                  // Form Fields
                  _buildFormFields(),
                  const SizedBox(height: 10),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Sign In Button
                  _buildSignInButton(),
                  const SizedBox(height: 16),
                  
                  // Sign Up Link
                  _buildSignUpLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: UiConst.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: UiConst.glowShadow,
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SocialLoginButton(
                icon: _buildGoogleIcon(),
                label: 'Google',
                onTap: () => _handleSocialLogin('Google'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialLoginButton(
                icon: const Icon(Icons.apple, color: Colors.white, size: 22),
                label: 'Apple',
                onTap: () => _handleSocialLogin('Apple'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SocialLoginButton(
          icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
          label: 'Continue with Facebook',
          onTap: () => _handleSocialLogin('Facebook'),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with email',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white54,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return AnimatedBuilder(
      animation: _fieldsController,
      builder: (context, child) {
        return Column(
          children: [
            _AnimatedField(
              animation: _fieldsController,
              index: 0,
              child: TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTypography.bodyMedium,
                decoration: _inputDecoration(
                  hint: 'Email',
                  icon: Icons.email_rounded,
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  final emailReg = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (value.isEmpty) return 'Email is required';
                  if (!emailReg.hasMatch(value)) return 'Enter a valid email';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 14),
            _AnimatedField(
              animation: _fieldsController,
              index: 1,
              child: TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: AppTypography.bodyMedium,
                decoration: _inputDecoration(
                  hint: 'Password',
                  icon: Icons.lock_rounded,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ),
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is LoginLoading;
          return AnimatedContainer(
            duration: UiConst.durationFast,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: UiConst.brandGradient),
              borderRadius: BorderRadius.circular(UiConst.radiusMedium),
              boxShadow: isLoading ? [] : UiConst.glowShadow,
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UiConst.radiusMedium),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: AppTypography.button.copyWith(
                        color: Colors.black,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New here?',
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white70,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signup');
          },
          child: Text(
            'Create account',
            style: AppTypography.labelLarge.copyWith(
              color: UiConst.amber,
            ),
          ),
        ),
      ],
    );
  }
}

/// Social login button with glassmorphism
class _SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(UiConst.radiusMedium),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (fullWidth || label.length <= 8) ...[
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated field with stagger effect
class _AnimatedField extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final Widget child;

  const _AnimatedField({
    required this.animation,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.2;
    final start = delay.clamp(0.0, 0.8);
    final end = (delay + 0.4).clamp(0.0, 1.0);

    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    final slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }
}
