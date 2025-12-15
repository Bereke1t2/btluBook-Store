import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

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

  // Controllers
  final _nameCtrl = TextEditingController(text: 'Alex Johnson');
  final _usernameCtrl = TextEditingController(text: 'alexj');
  final _emailCtrl = TextEditingController(text: 'alex.johnson@example.com');
  final _phoneCtrl = TextEditingController(text: '+1 202 555 0118');
  final _bioCtrl = TextEditingController(text: 'Reader. Designer. Coffee enthusiast.');
  final _address1Ctrl = TextEditingController(text: '221B Baker Street');
  final _address2Ctrl = TextEditingController(text: 'Marylebone');
  final _cityCtrl = TextEditingController(text: 'London');
  final _stateCtrl = TextEditingController(text: 'Greater London');
  final _zipCtrl = TextEditingController(text: 'NW1 6XE');

  // Password
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Selections
  String? _avatarUrl =
      'https://images.unsplash.com/photo-1544006659-f0b21884ce1d?q=80&w=480&auto=format&fit=crop';
  String _country = 'United Kingdom';
  ThemeMode _themeMode = ThemeMode.system;

  // Toggles
  bool _pushNoti = true;
  bool _emailNoti = true;
  bool _smsNoti = false;
  bool _twoFA = false;
  bool _marketing = true;
  bool _privateProfile = false;

  // Payment methods (mock)
  final List<_PaymentCard> _cards = [
    _PaymentCard(brand: 'Visa', last4: '4242', exp: '08/27', isDefault: true),
    _PaymentCard(brand: 'Mastercard', last4: '0077', exp: '12/26'),
  ];

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  InputDecoration _glassInput({
    required String hint,
    IconData? icon,
    Widget? suffix,
    EdgeInsets content = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                            title: 'Personal information',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _nameCtrl,
                                        style: const TextStyle(color: Colors.white),
                                        decoration:
                                            _glassInput(hint: 'Full name', icon: Icons.badge_rounded),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _usernameCtrl,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _glassInput(
                                            hint: 'Username', icon: Icons.alternate_email_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _emailCtrl,
                                        keyboardType: TextInputType.emailAddress,
                                        style: const TextStyle(color: Colors.white),
                                        decoration:
                                            _glassInput(hint: 'Email', icon: Icons.mail_rounded),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneCtrl,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(color: Colors.white),
                                        decoration:
                                            _glassInput(hint: 'Phone', icon: Icons.phone_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _bioCtrl,
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInput(
                                    hint: 'Bio',
                                    icon: Icons.edit_note_rounded,
                                    content: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _primaryButton(
                                    label: 'Save changes',
                                    icon: Icons.save_rounded,
                                    onTap: _saveProfile,
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
                            icon: Icons.location_on_rounded,
                            title: 'Address',
                            child: Column(
                              children: [
                                TextField(
                                  controller: _address1Ctrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInput(
                                    hint: 'Address line 1',
                                    icon: Icons.home_rounded,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _address2Ctrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInput(
                                    hint: 'Address line 2 (optional)',
                                    icon: Icons.apartment_rounded,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _cityCtrl,
                                        style: const TextStyle(color: Colors.white),
                                        decoration:
                                            _glassInput(hint: 'City', icon: Icons.location_city_rounded),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _stateCtrl,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _glassInput(
                                            hint: 'State/Province', icon: Icons.map_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _zipCtrl,
                                        keyboardType: TextInputType.text,
                                        style: const TextStyle(color: Colors.white),
                                        decoration:
                                            _glassInput(hint: 'ZIP/Postal code', icon: Icons.local_post_office_rounded),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _glassDropdown<String>(
                                        value: _country,
                                        icon: Icons.public_rounded,
                                        items: const [
                                          'United States',
                                          'United Kingdom',
                                          'Canada',
                                          'Germany',
                                          'France',
                                          'Ethiopia',
                                        ],
                                        onChanged: (v) => setState(() => _country = v ?? _country),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _primaryButton(
                                    label: 'Save address',
                                    icon: Icons.save_as_rounded,
                                    onTap: _saveAddress,
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
                                  onChanged: (v) => setState(() => _pushNoti = v),
                                ),
                                _switchRow(
                                  icon: Icons.mail_outline_rounded,
                                  label: 'Email updates',
                                  value: _emailNoti,
                                  onChanged: (v) => setState(() => _emailNoti = v),
                                ),
                                _switchRow(
                                  icon: Icons.sms_rounded,
                                  label: 'SMS alerts',
                                  value: _smsNoti,
                                  onChanged: (v) => setState(() => _smsNoti = v),
                                ),
                                _switchRow(
                                  icon: Icons.campaign_rounded,
                                  label: 'Marketing messages',
                                  value: _marketing,
                                  onChanged: (v) => setState(() => _marketing = v),
                                ),
                                const Divider(color: Colors.white24, height: 24),
                                Row(
                                  children: [
                                    _leadingIcon(Icons.brightness_6_rounded),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Theme',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    _themePill(
                                      label: 'System',
                                      selected: _themeMode == ThemeMode.system,
                                      onTap: () => setState(() => _themeMode = ThemeMode.system),
                                    ),
                                    const SizedBox(width: 6),
                                    _themePill(
                                      label: 'Light',
                                      selected: _themeMode == ThemeMode.light,
                                      onTap: () => setState(() => _themeMode = ThemeMode.light),
                                    ),
                                    const SizedBox(width: 6),
                                    _themePill(
                                      label: 'Dark',
                                      selected: _themeMode == ThemeMode.dark,
                                      onTap: () => setState(() => _themeMode = ThemeMode.dark),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                _switchRow(
                                  icon: Icons.lock_person_rounded,
                                  label: 'Private profile',
                                  value: _privateProfile,
                                  onChanged: (v) => setState(() => _privateProfile = v),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _switchRow(
                                  icon: Icons.verified_user_rounded,
                                  label: 'Two‑factor authentication',
                                  value: _twoFA,
                                  onChanged: (v) => setState(() => _twoFA = v),
                                ),
                                const SizedBox(height: 6),
                                _expander(
                                  headerIcon: Icons.password_rounded,
                                  header: 'Change password',
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _currentPassCtrl,
                                        obscureText: true,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _glassInput(
                                          hint: 'Current password',
                                          icon: Icons.lock_clock_rounded,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: _newPassCtrl,
                                        obscureText: true,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _glassInput(
                                          hint: 'New password',
                                          icon: Icons.lock_open_rounded,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: _confirmPassCtrl,
                                        obscureText: true,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _glassInput(
                                          hint: 'Confirm new password',
                                          icon: Icons.lock_reset_rounded,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: _primaryButton(
                                          label: 'Update password',
                                          icon: Icons.check_rounded,
                                          onTap: _updatePassword,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _leadingIcon(Icons.devices_other_rounded),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Active sessions',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    _secondaryButton(
                                      label: 'Manage',
                                      onTap: _manageSessions,
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _section(
                            icon: Icons.payment_rounded,
                            title: 'Payment methods',
                            child: Column(
                              children: [
                                for (final card in _cards) ...[
                                  _cardRow(card),
                                  const SizedBox(height: 8),
                                ],
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _primaryButton(
                                    label: 'Add card',
                                    icon: Icons.add_card_rounded,
                                    onTap: _addCardSheet,
                                  ),
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
                            title: 'Danger zone',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _leadingIcon(Icons.file_download_rounded),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Download my data',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    _secondaryButton(
                                      label: 'Request',
                                      onTap: _downloadData,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _leadingIcon(Icons.logout_rounded, color: Colors.redAccent),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Log out',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    _dangerButton(
                                      label: 'Log out',
                                      onTap: _logout,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _leadingIcon(Icons.delete_forever_rounded, color: Colors.red),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Delete account',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    _dangerButton(
                                      label: 'Delete',
                                      onTap: _confirmDelete,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: media.padding.bottom + 12)),
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
    final initials = _nameCtrl.text.trim().isEmpty
        ? 'U'
        : _nameCtrl.text
            .trim()
            .split(RegExp(r'\s+'))
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

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
                  child: _avatarUrl == null
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
                          _avatarUrl!,
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
                    child: const Icon(Icons.photo_camera_rounded, size: 18, color: Colors.white),
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
                  _nameCtrl.text,
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
                    _chip(icon: Icons.history_rounded, label: 'Orders: 12'),
                    _chip(icon: Icons.favorite_rounded, label: 'Wishlist: 7'),
                    _chip(icon: Icons.stars_rounded, label: 'Member: Gold'),
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
  Widget _section({required IconData icon, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _leadingIcon(icon),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
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
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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

  Widget _themePill({required String label, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: GlassContainer(
        borderRadius: 999,
        blurSigma: 12,
        color: selected ? _gold.withValues(alpha: 56 / 255) : Colors.white.withValues(alpha: 22 / 255),
        borderColor: selected ? _gold : Colors.white.withValues(alpha: 56 / 255),
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

  Widget _primaryButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _secondaryButton({required String label, required VoidCallback onTap}) {
    return GlassContainer(
      borderRadius: 12,
      blurSigma: 12,
      color: Colors.white.withValues(alpha: 22 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _expander({required IconData headerIcon, required String header, required Widget child}) {
    return _GlassExpansionTile(
      headerIcon: headerIcon,
      header: header,
      child: child,
    );
  }

  Widget _glassDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return GlassContainer(
      borderRadius: 14,
      blurSigma: 16,
      color: Colors.white.withValues(alpha: 26 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text('$e', style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          iconEnabledColor: Colors.white,
          dropdownColor: const Color(0xCC22313F),
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Actions

  void _saveProfile() async {
    final nameOk = _nameCtrl.text.trim().isNotEmpty;
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(_emailCtrl.text.trim());
    if (!nameOk || !emailOk) {
      _toast('Please enter a valid name and email.');
      return;
    }
    await _withProgress(() async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
    });
    _toast('Profile saved');
    setState(() {}); // refresh header
  }

  void _saveAddress() async {
    if (_address1Ctrl.text.trim().isEmpty || _cityCtrl.text.trim().isEmpty || _zipCtrl.text.trim().isEmpty) {
      _toast('Please complete your address.');
      return;
    }
    await _withProgress(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
    });
    _toast('Address saved');
  }

  void _updatePassword() async {
    final cur = _currentPassCtrl.text;
    final newP = _newPassCtrl.text;
    final con = _confirmPassCtrl.text;
    if (newP.length < 6 || newP != con || cur.isEmpty) {
      _toast('Check your password fields.');
      return;
    }
    await _withProgress(() async {
      await Future<void>.delayed(const Duration(milliseconds: 900));
    });
    _currentPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
    _toast('Password updated');
  }

  void _manageSessions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassContainer(
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
              const SizedBox(height: 8),
              _sessionRow(device: 'iPhone 15 Pro', location: 'London, UK', current: true),
              const Divider(color: Colors.white24),
              _sessionRow(device: 'Pixel 8', location: 'Berlin, DE'),
              const Divider(color: Colors.white24),
              _sessionRow(device: 'MacBook Pro', location: 'Addis Ababa, ET'),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: _dangerButton(
                  label: 'Sign out all',
                  onTap: () {
                    Navigator.pop(context);
                    _toast('Signed out from all devices');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessionRow({required String device, required String location, bool current = false}) {
    return Row(
      children: [
        _leadingIcon(Icons.devices_rounded, color: current ? _gold : Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                  )),
              const SizedBox(height: 2),
              Text(
                current ? '$location • Current session' : location,
                style: TextStyle(color: current ? _gold : Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        if (!current)
          _secondaryButton(
            label: 'Sign out',
            onTap: () => _toast('Session signed out'),
          ),
      ],
    );
  }

  void _addCardSheet() {
    final brandCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                TextField(
                  controller: brandCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _glassInput(hint: 'Brand (e.g., Visa)', icon: Icons.credit_card_rounded),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: numberCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _glassInput(hint: 'Card number', icon: Icons.numbers_rounded),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: expCtrl,
                  keyboardType: TextInputType.datetime,
                  style: const TextStyle(color: Colors.white),
                  decoration: _glassInput(hint: 'Expiry (MM/YY)', icon: Icons.calendar_month_rounded),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _primaryButton(
                    label: 'Add card',
                    icon: Icons.add_rounded,
                    onTap: () {
                      final digits = numberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                      if (brandCtrl.text.isEmpty || digits.length < 4 || expCtrl.text.length < 4) {
                        _toast('Please enter valid card details.');
                        return;
                      }
                      setState(() {
                        _cards.add(_PaymentCard(
                          brand: brandCtrl.text.trim(),
                          last4: digits.substring(digits.length - 4),
                          exp: expCtrl.text.trim(),
                        ));
                      });
                      Navigator.pop(context);
                      _toast('Card added');
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

  Widget _cardRow(_PaymentCard card) {
    return GlassContainer(
      borderRadius: 14,
      blurSigma: 14,
      color: Colors.white.withValues(alpha: 18 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _leadingIcon(Icons.credit_card_rounded, color: card.isDefault ? _gold : Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${card.brand} •••• ${card.last4}  •  ${card.exp}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          if (!card.isDefault)
            _secondaryButton(
              label: 'Make default',
              onTap: () {
                setState(() {
                  for (final c in _cards) {
                    c.isDefault = false;
                  }
                  card.isDefault = true;
                });
                _toast('Default payment method updated');
              },
            ),
          const SizedBox(width: 6),
          _dangerButton(
            label: 'Remove',
            onTap: () {
              setState(() => _cards.remove(card));
              _toast('Card removed');
            },
          ),
        ],
      ),
    );
  }

  void _downloadData() async {
    await _withProgress(() async {
      await Future<void>.delayed(const Duration(milliseconds: 900));
    });
    _toast('Export started. You’ll receive an email.');
  }

  void _logout() async {
    final ok = await _confirm(
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log out',
    );
    if (ok) {
      _toast('Logged out');
      // Navigate to login screen if needed
    }
  }

  void _confirmDelete() async {
    final ok = await _confirm(
      title: 'Delete account',
      message:
          'This will permanently remove your account and data. This action cannot be undone.',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (ok) {
      await _withProgress(() async {
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      _toast('Account deleted');
      // Navigate out if needed
    }
  }

  // Photo change sheet (no external plugins; presets and URL supported)
  void _changePhotoSheet() {
    final urlCtrl = TextEditingController();
    final presets = const [
      'https://images.unsplash.com/photo-1544006659-f0b21884ce1d?q=80&w=480&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?q=80&w=480&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=480&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?q=80&w=480&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1541534401786-2077eed87a72?q=80&w=480&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?q=80&w=480&auto=format&fit=crop',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Choose a preset', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: presets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final url = presets[i];
                      return InkWell(
                        onTap: () {
                          setState(() => _avatarUrl = url);
                          Navigator.pop(context);
                          _toast('Profile photo updated');
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            children: [
                              Image.network(
                                url,
                                width: 84,
                                height: 84,
                                fit: BoxFit.cover,
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _avatarUrl == url ? _gold : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('From URL', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 8),
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
                    _primaryButton(
                      label: 'Apply',
                      icon: Icons.check_rounded,
                      onTap: () {
                        if (urlCtrl.text.trim().isEmpty) {
                          _toast('Enter a valid image URL.');
                          return;
                        }
                        setState(() => _avatarUrl = urlCtrl.text.trim());
                        Navigator.pop(context);
                        _toast('Profile photo updated');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _dangerButton(
                    label: 'Remove photo',
                    onTap: () {
                      setState(() => _avatarUrl = null);
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
                Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 8),
                Text(message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
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
                          : _primaryButton(
                              label: confirmLabel,
                              icon: Icons.check_rounded,
                              onTap: () => Navigator.pop(context, true),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// Model
class _PaymentCard {
  final String brand;
  final String last4;
  final String exp;
  bool isDefault;
  _PaymentCard({
    required this.brand,
    required this.last4,
    required this.exp,
    this.isDefault = false,
  });
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
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              Transform.rotate(
                angle: _open ? 3.1415 : 0,
                child: const Icon(Icons.expand_more_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          crossFadeState: _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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