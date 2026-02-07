import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/const/app_typography.dart';
import 'GlassContainer.dart';

class PaymentOptionsSheet extends StatelessWidget {
  final double amount;
  final VoidCallback onPaymentSuccess;

  const PaymentOptionsSheet({
    super.key, 
    required this.amount, 
    required this.onPaymentSuccess
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, media.viewInsets.bottom + 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B), // Dark slate bg
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Unlock this Book',
            style: AppTypography.headlineMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Support the author by purchasing this book for \$${amount.toStringAsFixed(2)}',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          _buildPaymentOption(
            context,
            icon: Icons.mobile_friendly_rounded,
            title: 'Telebirr',
            color: const Color(0xFF1E88E5), // Blueish
            onTap: () => _simulatePayment(context),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            context,
            icon: Icons.account_balance_rounded,
            title: 'CBE Birr',
            color: const Color(0xFF7B1FA2), // Purpleish
            onTap: () => _simulatePayment(context),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            context,
            icon: Icons.credit_card_rounded,
            title: 'Credit Card',
            color: const Color(0xFFF2C94C), // Brand Gold
            onTap: () => _simulatePayment(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 16,
        color: Colors.white.withValues(alpha: 0.05),
        borderColor: Colors.white.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white, 
                fontWeight: FontWeight.w600
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  void _simulatePayment(BuildContext context) {
    Navigator.pop(context); // Close sheet
    
    // Simulate loading/success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment Successful! Downloading...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    onPaymentSuccess();
  }
}
