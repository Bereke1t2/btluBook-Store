import 'dart:ui' as ui;
import 'package:ethio_book_store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/const/ui_const.dart';
import '../../../../core/const/app_typography.dart';
import '../widgets/GlowCircle.dart';

/// Enhanced Signup Page with:
/// - Social login buttons (UI only)
/// - Password strength indicator
/// - Smooth entrance animations
/// - Improved design
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with TickerProviderStateMixin {
  // Background animation
  late final AnimationController _bgController;
  
  // Card entrance animation
  late final AnimationController _entranceController;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;
  
  // Fields animation
  late final AnimationController _fieldsController;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  // Password strength tracking
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    
    _bgController = AnimationController(
      vsync: this,
      duration: UiConst.durationBackground,
    )..repeat(reverse: true);
    
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
    
    _fieldsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Listen to password changes
    _passwordCtrl.addListener(_updatePasswordStrength);

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fieldsController.forward();
  }

  void _updatePasswordStrength() {
    final password = _passwordCtrl.text;
    double strength = 0;
    
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthLabel = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }
    
    // Length check
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 8) strength += 0.1;
    if (password.length >= 12) strength += 0.1;
    
    // Lowercase check
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    
    // Uppercase check
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    
    // Number check
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    
    // Special character check
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    String label;
    Color color;
    
    if (strength < 0.3) {
      label = 'Weak';
      color = UiConst.error;
    } else if (strength < 0.5) {
      label = 'Fair';
      color = UiConst.warning;
    } else if (strength < 0.7) {
      label = 'Good';
      color = UiConst.info;
    } else {
      label = 'Strong';
      color = UiConst.success;
    }

    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
      _passwordStrengthLabel = label;
      _passwordStrengthColor = color;
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    _fieldsController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      if (!mounted) return;
      context.read<AuthBloc>().add(
            SignupRequested(
              username: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
            ),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  void _handleSocialSignup(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider signup coming soon!'),
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
              if (state is SignupSuccess) {
                Navigator.of(context).pushReplacementNamed('/home');
              } else if (state is SignupFailure) {
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
                  // Glow circles
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
                  
                  // Main card
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
                      child: _buildSignupCard(),
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

  Widget _buildSignupCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiConst.radiusXLarge),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: UiConst.blurMedium,
          sigmaY: UiConst.blurMedium,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 26),
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
                  const SizedBox(height: 12),
                  
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: UiConst.brandTextGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'Join Us',
                      textAlign: TextAlign.center,
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your account to get started',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Social Login
                  _buildSocialLoginSection(),
                  const SizedBox(height: 16),
                  
                  // Divider
                  _buildDivider(),
                  const SizedBox(height: 16),
                  
                  // Form Fields
                  _buildFormFields(),
                  const SizedBox(height: 8),
                  
                  // Password Strength Indicator
                  if (_passwordCtrl.text.isNotEmpty) _buildPasswordStrength(),
                  const SizedBox(height: 16),
                  
                  // Sign Up Button
                  _buildSignUpButton(),
                  const SizedBox(height: 14),
                  
                  // Sign In Link
                  _buildSignInLink(),
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
      width: 60,
      height: 60,
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
        Icons.person_add_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: _buildGoogleIcon(),
            label: 'Google',
            onTap: () => _handleSocialSignup('Google'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            icon: const Icon(Icons.apple, color: Colors.white, size: 20),
            label: 'Apple',
            onTap: () => _handleSocialSignup('Apple'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 20),
            label: 'Facebook',
            onTap: () => _handleSocialSignup('Facebook'),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
                colors: [Colors.transparent, Colors.white.withOpacity(0.3)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or with email',
            style: AppTypography.labelSmall.copyWith(color: Colors.white54),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.3), Colors.transparent],
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
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: AppTypography.bodyMedium,
                decoration: _inputDecoration(
                  hint: 'Full name',
                  icon: Icons.person_rounded,
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Name is required';
                  if (value.length < 2) return 'Enter a valid name';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedField(
              animation: _fieldsController,
              index: 1,
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
            const SizedBox(height: 12),
            _AnimatedField(
              animation: _fieldsController,
              index: 2,
              child: TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePwd,
                style: AppTypography.bodyMedium,
                decoration: _inputDecoration(
                  hint: 'Password',
                  icon: Icons.lock_rounded,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                    icon: Icon(
                      _obscurePwd ? Icons.visibility_rounded : Icons.visibility_off_rounded,
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
            const SizedBox(height: 12),
            _AnimatedField(
              animation: _fieldsController,
              index: 3,
              child: TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                style: AppTypography.bodyMedium,
                decoration: _inputDecoration(
                  hint: 'Confirm password',
                  icon: Icons.lock_person_rounded,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ),
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty) return 'Confirm your password';
                  if (value != _passwordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordStrength() {
    return AnimatedContainer(
      duration: UiConst.durationFast,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strength bar
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AnimatedContainer(
                duration: UiConst.durationMedium,
                curve: Curves.easeOutCubic,
                height: 4,
                width: (MediaQuery.of(context).size.width - 52) * _passwordStrength * 0.9, // max width
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _passwordStrengthColor.withOpacity(0.8),
                      _passwordStrengthColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: _passwordStrengthColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Strength label and indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _passwordStrength >= 0.7 ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    size: 14,
                    color: _passwordStrengthColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _passwordStrengthLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: _passwordStrengthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _StrengthDot(
                    active: _passwordCtrl.text.contains(RegExp(r'[A-Z]')),
                    label: 'A-Z',
                  ),
                  const SizedBox(width: 8),
                  _StrengthDot(
                    active: _passwordCtrl.text.contains(RegExp(r'[0-9]')),
                    label: '0-9',
                  ),
                  const SizedBox(width: 8),
                  _StrengthDot(
                    active: _passwordCtrl.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
                    label: '@#\$',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is SignupLoading;
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
                      'Create Account',
                      style: AppTypography.button.copyWith(color: Colors.black),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
        ),
        TextButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          child: Text(
            'Sign in',
            style: AppTypography.labelLarge.copyWith(color: UiConst.amber),
          ),
        ),
      ],
    );
  }
}

/// Social button
class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(UiConst.radiusMedium),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

/// Strength requirement dot
class _StrengthDot extends StatelessWidget {
  final bool active;
  final String label;

  const _StrengthDot({
    required this.active,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: UiConst.durationFast,
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? UiConst.sage : Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: active ? Colors.white70 : Colors.white38,
            fontSize: 9,
          ),
        ),
      ],
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
    final delay = index * 0.15;
    final start = delay.clamp(0.0, 0.7);
    final end = (delay + 0.3).clamp(0.0, 1.0);

    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    final slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
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
