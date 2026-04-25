import 'package:flutter/material.dart';
import 'package:hisabati/core/exts.dart';

import '../theme/app_theme.dart';

class BalanceHeader extends StatelessWidget {
  final double totalCredit;
  final double totalDebit;
  const BalanceHeader(
      {super.key, 
      required this.totalCredit, required this.totalDebit
      });
  Widget _buildBalanceItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 14),
        const SizedBox(height: 4),
        Text(
         amount.formatAmount,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'myfont',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontFamily: 'myfont',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildBalanceItem(
            'لي ',
            totalCredit,
            AppColors.primaryLight,
            Icons.arrow_upward_rounded,
          ),
        ),
        Container(width: 1, height: 42, color: Colors.white.withOpacity(0.2)),
        Expanded(
          child: _buildBalanceItem(
            'عليا',
            totalDebit,
            const Color(0xFFFF8A80),
            Icons.arrow_downward_rounded,
          ),
        ),
        Container(width: 1, height: 42, color: Colors.white.withOpacity(0.2)),
        Expanded(
          child: _buildBalanceItem(
            'الرصيد',
            totalCredit-totalDebit,
            (totalCredit-totalDebit)>0 ?AppColors.success:AppColors.error,
            Icons.account_balance_wallet_rounded,
          ),
        ),
      ],
    );
  }
}
