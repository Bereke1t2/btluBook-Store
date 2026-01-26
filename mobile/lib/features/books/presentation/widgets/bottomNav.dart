import 'package:ethio_book_store/features/auth/domain/entities/user.dart';
import 'package:ethio_book_store/features/books/presentation/pages/uploadscrean.dart';
import 'package:ethio_book_store/features/books/presentation/pages/user_profile_page.dart' hide GlassContainer;
import 'package:flutter/material.dart';

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFF2C94C) : Colors.white70;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget BuildBottomNav({
  required BuildContext context,
  required int navIndex,
  required ValueChanged<int> onSelect,
  required Object user,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: GlassContainer(
    borderRadius: 18,
    color: Colors.white.withOpacity(26 / 255),
    borderColor: Colors.white.withOpacity(56 / 255),
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: navIndex == 0,
            onTap: () {
              if (navIndex != 0) {
                onSelect(0);
              }
            },
          ),
          _NavItem(
            icon: Icons.cloud_download_outlined,
            label: 'Download',
            selected: navIndex == 1,
            onTap: () async {
              onSelect(1);
              await Navigator.pushNamed(
                context,
                '/Download',
                arguments: {'user': user},
              );
              onSelect(0);
            },
          ),
          _NavItem(
            icon: Icons.cloud_upload_outlined,
            label: 'Upload',
            selected: navIndex == 2,
            onTap: () async {
              onSelect(2);
              await Navigator.pushNamed(context, '/UploadPage');
              onSelect(0);
            },
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: navIndex == 3,
            onTap: () async {
              onSelect(3);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserProfilePage(user: user as User)),
              );
              onSelect(0);
            },
          ),
        ],
      ),
    ),
  );
}
