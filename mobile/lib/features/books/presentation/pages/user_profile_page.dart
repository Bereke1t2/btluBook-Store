import 'dart:ui' as ui;
import 'package:ethio_book_store/features/auth/domain/entities/user.dart';
import 'package:ethio_book_store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfilePage extends StatefulWidget {
  final User user;
  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  // Theming
  static const _gold = Color(0xFFF2C94C);
  static const _ink = Color(0xFF0D1B2A);
  static const _slate = Color(0xFF233542);
  static const _leather = Color(0xFF3A2F2A);

  // Animated background
  late final AnimationController _bgController;

  // User entity fields
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  String? _profileImage; // users.profile_image

  // Derived stats (these would come from backend users.*)
  late int _booksReadCount;
  late int _readingStreak;
  DateTime? _lastReadDate;
  late int _points;

  // Password
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Preferences (local UI only)
  ThemeMode _themeMode = ThemeMode.system;
  bool _pushNoti = true;
  bool _emailNoti = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Initialize state from widget.user
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _profileImage =
        widget.user.profileImage ??
        'https://images.unsplash.com/photo-1544006659-f0b21884ce1d?q=80&w=480&auto=format&fit=crop';
    _booksReadCount = widget.user.booksReadCount;
    _readingStreak = widget.user.readingStreak;
    _lastReadDate = widget.user.lastReadDate;
    _points = widget.user.points;
  }

  @override
  void didUpdateWidget(covariant UserProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _usernameCtrl.text = widget.user.username;
      _emailCtrl.text = widget.user.email;
      setState(() {
        _profileImage =
            widget.user.profileImage ??
            'https://images.unsplash.com/photo-1544006659-f0b21884ce1d?q=80&w=480&auto=format&fit=crop';
        _booksReadCount = widget.user.booksReadCount;
        _readingStreak = widget.user.readingStreak;
        _lastReadDate = widget.user.lastReadDate;
        _points = widget.user.points;
      });
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  InputDecoration _glassInput({
    required String hint,
    IconData? icon,
    Widget? suffix,
    EdgeInsets content = const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 16,
    ),
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 26 / 255),
      hintStyle: const TextStyle(color: Colors.white70),
      contentPadding: content,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 64 / 255)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;

    return Scaffold(
      extendBody: true,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (_, __) {
          final t = Curves.easeInOut.transform(_bgController.value);
          final begin = Alignment.lerp(
            Alignment.bottomLeft,
            Alignment.topRight,
            t,
          )!;
          final end = Alignment.lerp(
            Alignment.topRight,
            Alignment.bottomLeft,
            t,
          )!;
          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                // Update user info if changed
                if (state.user != widget.user) {
                  _usernameCtrl.text = state.user.username;
                  _emailCtrl.text = state.user.email;
                  setState(() {
                    _profileImage =
                        state.user.profileImage ??
                        'https://images.unsplash.com/photo-1544006659-f0b21884ce1d?q=80&w=480&auto=format&fit=crop';
                    _booksReadCount = state.user.booksReadCount;
                    _readingStreak = state.user.readingStreak;
                    _lastReadDate = state.user.lastReadDate;
                    _points = state.user.points;
                  });
                }
              } else if (state is LogoutSuccess) {
                Navigator.of(context).pushReplacementNamed('/login');
              } else if (state is LogoutFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: ${state.message}')),
                );
              }
            },
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: const [_ink, _slate, _leather],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      left: -80,
                      top: -60,
                      child: GlowCircle(size: 280, color: _gold),
                    ),
                    const Positioned(
                      right: -90,
                      bottom: -60,
                      child: GlowCircle(size: 330, color: Color(0xFFA1E3B5)),
                    ),
                    const Positioned(
                      right: -10,
                      top: 120,
                      child: GlowCircle(size: 160, color: Color(0xFFD9CBAA)),
                    ),
                    SafeArea(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: _buildHeader(context)),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                              child: _buildAvatarCard(width),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: _section(
                                icon: Icons.person_rounded,
                                title: 'Account',
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _usernameCtrl,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: _glassInput(
                                              hint: 'Username',
                                              icon:
                                                  Icons.alternate_email_rounded,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller: _emailCtrl,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: _glassInput(
                                              hint: 'Email',
                                              icon: Icons.mail_rounded,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        return Align(
                                          alignment: Alignment.centerRight,
                                          child: _primaryButton(
                                            label: 'Save',
                                            icon: Icons.save_rounded,
                                            onTap: _saveAccount,
                                            state: state,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: _section(
                                icon: Icons.insights_rounded,
                                title: 'Reading stats',
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _chip(
                                      icon: Icons.menu_book_rounded,
                                      label: 'Books read: $_booksReadCount',
                                    ),
                                    _chip(
                                      icon: Icons.local_fire_department_rounded,
                                      label: 'Streak: $_readingStreak',
                                    ),
                                    _chip(
                                      icon: Icons.today_rounded,
                                      label:
                                          'Last read: ${_lastReadDate == null ? '—' : _fmtDate(_lastReadDate!)}',
                                    ),
                                    _chip(
                                      icon: Icons.stars_rounded,
                                      label: 'Points: $_points',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: _section(
                                icon: Icons.security_rounded,
                                title: 'Security',
                                child: Column(
                                  children: [
                                    _expander(
                                      headerIcon: Icons.password_rounded,
                                      header: 'Change password',
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: _currentPassCtrl,
                                            obscureText: true,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: _glassInput(
                                              hint: 'Current password',
                                              icon: Icons.lock_clock_rounded,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: _newPassCtrl,
                                            obscureText: true,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: _glassInput(
                                              hint: 'New password',
                                              icon: Icons.lock_open_rounded,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: _confirmPassCtrl,
                                            obscureText: true,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: _glassInput(
                                              hint: 'Confirm new password',
                                              icon: Icons.lock_reset_rounded,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child:
                                                BlocBuilder<
                                                  AuthBloc,
                                                  AuthState
                                                >(
                                                  builder: (context, state) {
                                                    return _primaryButton(
                                                      state: state,
                                                      label: 'Update',
                                                      icon: Icons.check_rounded,
                                                      onTap: _updatePassword,
                                                    );
                                                  },
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: _section(
                                icon: Icons.settings_suggest_rounded,
                                title: 'Preferences',
                                child: Column(
                                  children: [
                                    _switchRow(
                                      icon: Icons.notifications_active_rounded,
                                      label: 'Push notifications',
                                      value: _pushNoti,
                                      onChanged: (v) =>
                                          setState(() => _pushNoti = v),
                                    ),
                                    _switchRow(
                                      icon: Icons.mail_outline_rounded,
                                      label: 'Email updates',
                                      value: _emailNoti,
                                      onChanged: (v) =>
                                          setState(() => _emailNoti = v),
                                    ),
                                    const Divider(
                                      color: Colors.white24,
                                      height: 24,
                                    ),
                                    Row(
                                      children: [
                                        _leadingIcon(
                                          Icons.brightness_6_rounded,
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(
                                          child: Text(
                                            'Theme',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        _themePill(
                                          label: 'System',
                                          selected:
                                              _themeMode == ThemeMode.system,
                                          onTap: () => setState(
                                            () => _themeMode = ThemeMode.system,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        _themePill(
                                          label: 'Light',
                                          selected:
                                              _themeMode == ThemeMode.light,
                                          onTap: () => setState(
                                            () => _themeMode = ThemeMode.light,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        _themePill(
                                          label: 'Dark',
                                          selected:
                                              _themeMode == ThemeMode.dark,
                                          onTap: () => setState(
                                            () => _themeMode = ThemeMode.dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: _section(
                                icon: Icons.warning_amber_rounded,
                                title: 'Session',
                                child: Row(
                                  children: [
                                    _leadingIcon(
                                      Icons.logout_rounded,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Log out',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        if (state is LogoutLoading) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        return _dangerButton(
                                          label: 'Log out',
                                          onTap: _logout,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(height: media.padding.bottom + 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.maybePop(context),
            child: GlassContainer(
              borderRadius: 999,
              padding: const EdgeInsets.all(8),
              blurSigma: 16,
              color: Colors.white.withValues(alpha: 22 / 255),
              borderColor: Colors.white.withValues(alpha: 56 / 255),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Colors.white, Color(0xFFFFF1CC), _gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(r),
              blendMode: BlendMode.srcIn,
              child: Text(
                'Profile',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GlassContainer(
            borderRadius: 12,
            blurSigma: 16,
            color: Colors.white.withValues(alpha: 22 / 255),
            borderColor: Colors.white.withValues(alpha: 56 / 255),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.help_outline_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Avatar card
  Widget _buildAvatarCard(double width) {
    final initials = _usernameCtrl.text.trim().isEmpty
        ? 'U'
        : _usernameCtrl.text.trim().substring(0, 1).toUpperCase();

    return GlassContainer(
      borderRadius: 20,
      blurSigma: 20,
      color: Colors.white.withValues(alpha: 26 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_gold, Color(0xFFD4A373)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 90 / 255),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profileImage == null || _profileImage!.isEmpty
                      ? Container(
                          color: Colors.black26,
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        )
                      : Image.network(
                          _profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _changePhotoSheet,
                  borderRadius: BorderRadius.circular(999),
                  child: GlassContainer(
                    borderRadius: 999,
                    blurSigma: 14,
                    color: Colors.white.withValues(alpha: 28 / 255),
                    borderColor: Colors.white.withValues(alpha: 76 / 255),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _usernameCtrl.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailCtrl.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(
                      icon: Icons.menu_book_rounded,
                      label: 'Books: $_booksReadCount',
                    ),
                    _chip(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Streak: $_readingStreak',
                    ),
                    _chip(icon: Icons.stars_rounded, label: 'Points: $_points'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helpers: section container
  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _leadingIcon(icon),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GlassContainer(
          borderRadius: 18,
          blurSigma: 18,
          color: Colors.white.withValues(alpha: 22 / 255),
          borderColor: Colors.white.withValues(alpha: 56 / 255),
          padding: const EdgeInsets.all(14),
          child: child,
        ),
      ],
    );
  }

  Widget _leadingIcon(IconData icon, {Color color = Colors.white}) {
    return GlassContainer(
      borderRadius: 12,
      blurSigma: 16,
      color: Colors.white.withValues(alpha: 18 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: color),
    );
  }

  Widget _chip({required IconData icon, required String label}) {
    return GlassContainer(
      borderRadius: 999,
      blurSigma: 12,
      color: Colors.white.withValues(alpha: 22 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _gold),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        _leadingIcon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          activeTrackColor: _gold,
          inactiveThumbColor: Colors.white70,
          inactiveTrackColor: Colors.white30,
        ),
      ],
    );
  }

  Widget _themePill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: GlassContainer(
        borderRadius: 999,
        blurSigma: 12,
        color: selected
            ? _gold.withValues(alpha: 56 / 255)
            : Colors.white.withValues(alpha: 22 / 255),
        borderColor: selected
            ? _gold
            : Colors.white.withValues(alpha: 56 / 255),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required AuthState state,
  }) {
    final isLoading = state is UpdateProfileLoading;
    final isFailure = state is UpdateProfileFailure;

    return SizedBox(
      height: 44,
      child: isFailure
          ? Text(
              'Failed to update profile ${state is UpdateProfileFailure ? (state).message : ''}',
              style: const TextStyle(color: Colors.red),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isLoading ? null : Icon(icon),
              label: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      borderRadius: 12,
      blurSigma: 12,
      color: Colors.white.withValues(alpha: 22 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _dangerButton({required String label, required VoidCallback onTap}) {
    return GlassContainer(
      borderRadius: 12,
      blurSigma: 12,
      color: Colors.red.withValues(alpha: 28 / 255),
      borderColor: Colors.redAccent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _expander({
    required IconData headerIcon,
    required String header,
    required Widget child,
  }) {
    return _GlassExpansionTile(
      headerIcon: headerIcon,
      header: header,
      child: child,
    );
  }

  // Actions

  void _saveAccount() async {
    final usernameOk = _usernameCtrl.text.trim().isNotEmpty;
    final emailOk = RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    ).hasMatch(_emailCtrl.text.trim());
    if (!usernameOk || !emailOk) {
      _toast('Enter a valid username and email.');
      return;
    }
    context.read<AuthBloc>().add(
      UpdateProfileRequested(
        user: User(
          id: widget.user.id,
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          profileImage: _profileImage,
          passwordHash: widget.user.passwordHash,
          createdAt: widget.user.createdAt,
          updatedAt: DateTime.now(),
        ),
      ),
    );
    _toast('Account saved');
    setState(() {});
  }

  void _updatePassword() async {
    final cur = _currentPassCtrl.text;
    final newP = _newPassCtrl.text;
    final con = _confirmPassCtrl.text;
    if (newP.length < 6 || newP != con || cur.isEmpty) {
      _toast('Check your password fields.');
      return;
    }
    context.read<AuthBloc>().add(
      UpdateProfileRequested(
        user: User(
          id: widget.user.id,
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          profileImage: _profileImage,
          passwordHash: _newPassCtrl.text.trim(),
          createdAt: widget.user.createdAt,
          updatedAt: DateTime.now(),
        ),
      ),
    );
    _currentPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
    _toast('Password updated');
  }

  void _logout() async {
    final ok = await _confirm(
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log out',
    );
    if (ok) {
      context.read<AuthBloc>().add(LogoutRequested());
      _toast('Logged out');
    }
  }

  // Photo change sheet -> updates users.profile_image
  void _changePhotoSheet() {
    final urlCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GlassContainer(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.all(16),
          borderRadius: 24,
          blurSigma: 26,
          color: Colors.white.withValues(alpha: 24 / 255),
          borderColor: Colors.white.withValues(alpha: 66 / 255),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.photo_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Change profile photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: urlCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _glassInput(
                          hint: 'Paste image URL...',
                          icon: Icons.link_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return _primaryButton(
                          label: 'Apply',
                          icon: Icons.check_rounded,
                          state: state,
                          onTap: () async {
                            final url = urlCtrl.text.trim();
                            if (url.isEmpty) {
                              _toast('Enter a valid image URL.');
                              return;
                            }
                            context.read<AuthBloc>().add(
                              UpdateProfileRequested(
                                user: User(
                                  id: widget.user.id,
                                  username: _usernameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  profileImage: _profileImage,
                                  passwordHash: widget.user.passwordHash,
                                  createdAt: widget.user.createdAt,
                                  updatedAt: DateTime.now(),
                                ),
                              ),
                            );
                            setState(() => _profileImage = url);
                            Navigator.pop(context);
                            _toast('Profile photo updated');
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _dangerButton(
                    label: 'Remove photo',
                    onTap: () async {
                      await _withProgress(() async {
                        // TODO: call backend set users.profile_image = NULL
                        await Future<void>.delayed(
                          const Duration(milliseconds: 400),
                        );
                      });
                      setState(() => _profileImage = null);
                      Navigator.pop(context);
                      _toast('Photo removed');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Common UI
  Widget _sheetHandle() {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 90 / 255),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Future<void> _withProgress(Future<void> Function() task) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: GlassContainer(
          borderRadius: 18,
          blurSigma: 18,
          color: Colors.white.withValues(alpha: 28 / 255),
          borderColor: Colors.white.withValues(alpha: 66 / 255),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: _gold,
                ),
              ),
              SizedBox(width: 12),
              Text('Please wait...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
    try {
      await task();
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool danger = false,
  }) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => Center(
        child: GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          borderRadius: 20,
          blurSigma: 22,
          color: Colors.white.withValues(alpha: 28 / 255),
          borderColor: Colors.white.withValues(alpha: 66 / 255),
          padding: const EdgeInsets.all(16),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _secondaryButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: danger
                          ? _dangerButton(
                              label: confirmLabel,
                              onTap: () => Navigator.pop(context, true),
                            )
                          : BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return _primaryButton(
                                  state: state,
                                  label: confirmLabel,
                                  icon: Icons.check_rounded,
                                  onTap: () => Navigator.pop(context, true),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return ok ?? false;
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

// Glow circle used in the background
class GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const GlowCircle({
    super.key,
    required this.size,
    required this.color,
    this.blur = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 160 / 255),
              blurRadius: blur,
              spreadRadius: blur * 0.35,
            ),
          ],
        ),
      ),
    );
  }
}

// Glass container (frosted)
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color color;
  final Color borderColor;

  const GlassContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurSigma = 18,
    this.color = const Color(0x33000000),
    this.borderColor = const Color(0x66FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 36 / 255),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// A compact glass expansion tile (no external package)
class _GlassExpansionTile extends StatefulWidget {
  final IconData headerIcon;
  final String header;
  final Widget child;

  const _GlassExpansionTile({
    required this.headerIcon,
    required this.header,
    required this.child,
  });

  @override
  State<_GlassExpansionTile> createState() => _GlassExpansionTileState();
}

class _GlassExpansionTileState extends State<_GlassExpansionTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _open = !_open),
          child: Row(
            children: [
              _leadingIcon(widget.headerIcon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.header,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Transform.rotate(
                angle: _open ? 3.1415 : 0,
                child: const Icon(
                  Icons.expand_more_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          crossFadeState: _open
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 220),
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: widget.child,
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _leadingIcon(IconData icon) {
    return GlassContainer(
      borderRadius: 12,
      blurSigma: 16,
      color: Colors.white.withValues(alpha: 18 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white),
    );
  }
}
