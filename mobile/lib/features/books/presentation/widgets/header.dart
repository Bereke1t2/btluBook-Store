 import 'package:ethio_book_store/features/books/presentation/widgets/GlassBtnIcon.dart';
import 'package:flutter/material.dart';

Widget Header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF2C94C), Color(0xFFD4A373)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF2C94C).withValues(alpha: 89 / 255),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Colors.white, Color(0xFFFFF1CC), Color(0xFFF2C94C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(r),
              blendMode: BlendMode.srcIn,
              child: Text(
                'btluBook Store',
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
          GlassIconBtn(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          GlassIconBtn(
            icon: Icons.person_outline_rounded,
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }