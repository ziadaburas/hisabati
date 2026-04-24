import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/entries_controller.dart';
import '../../models/entry_model.dart';
import '../../theme/app_theme.dart';
import '../customer_entries/customer_entries_view.dart';

class CustomersView extends StatelessWidget {
   CustomersView({super.key});
   var isDark = false;
   final amountFormatter = NumberFormat('#,##0.##', 'en_US');

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EntriesController>();
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryMedium),
          );
        }

        final customers = controller.customerSummaries;

        if (customers.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index].value;
            return _buildEntryTile(context, customer);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_rounded,
              size: 44,
              color: AppColors.primaryDark.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'لا يوجد عملاء بعد',
            style: TextStyle(
              fontSize: 17,
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w600,
              fontFamily: 'myfont',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'أضف قيداً مع اسم عميل للبدء',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSubtitle,
              fontFamily: 'myfont',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    CustomerSummary customer,
    NumberFormat amountFormatter,
  ) {
    final balance = customer.totalCredit - customer.totalDebit;
    final isPositive = balance >= 0;
    final balanceColor = isPositive ? AppColors.success : AppColors.error;

    // Get initials
    final initial = customer.name.isNotEmpty
        ? customer.name[0].toUpperCase()
        : '?';

    // Avatar color based on first letter
    final colors = [
      AppColors.primaryMedium,
      const Color(0xFF2E86AB),
      const Color(0xFF8B5E3C),
      const Color(0xFF6B4C93),
      AppColors.warning,
    ];
    final colorIndex = customer.name.isEmpty ? 0 : customer.name.codeUnitAt(0) % colors.length;
    final avatarColor = colors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.cardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.to(() => CustomerEntriesView(customerName: customer.name)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'myfont',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'myfont',
                              color: isDark ? Colors.white:Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: balanceColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${isPositive ? '+' : ''}${amountFormatter.format(balance)}',
                            style: TextStyle(
                              color: balanceColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'myfont',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Entries count
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 13,
                          color: AppColors.textSubtitle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.entryCount} قيد',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSubtitle,
                            fontFamily: 'myfont',
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Credit
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          amountFormatter.format(customer.totalCredit),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontFamily: 'myfont',
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Debit
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          amountFormatter.format(customer.totalDebit),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontFamily: 'myfont',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(
                Icons.arrow_back_ios_rounded,
                size: 14,
                color: AppColors.mediumGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
    
    Widget _buildEntryTile(
    BuildContext context,
    CustomerSummary customer,
   
  ) {
    final colors = [
      AppColors.primaryMedium,
      const Color(0xFF2E86AB),
      const Color(0xFF8B5E3C),
      const Color(0xFF6B4C93),
      AppColors.warning,
    ];
    final colorIndex = customer.name.isEmpty ? 0 : customer.name.codeUnitAt(0) % colors.length;
    final avatarColor = colors[colorIndex];

     final balance = customer.totalCredit - customer.totalDebit;
    final isPositive = balance >= 0;
    final balanceColor = isPositive ? AppColors.success : AppColors.error;
    final initial = customer.name.isNotEmpty
        ? customer.name[0].toUpperCase()
        : '?';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isDark ? 0 : 1,
      color: isDark ? AppColors.darkCard : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? BorderSide(color: AppColors.darkDivider) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => CustomerEntriesView(customerName: customer.name)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              right: BorderSide(
                color: balanceColor,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'myfont',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                           customer.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'myfont',
                            color:balanceColor,
                          ),
                        ),
                        // Text(
                        //  "ccc",
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16,
                        //     fontFamily: 'myfont',
                        //     color: balanceColor,
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 12, color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                        '${customer.entryCount} قيد',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'myfont',
                            color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Credit
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          amountFormatter.format(customer.totalCredit),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontFamily: 'myfont',
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Debit
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          amountFormatter.format(customer.totalDebit),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontFamily: 'myfont',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: balanceColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${isPositive ? '+' : ''}${amountFormatter.format(balance)}',
                            style: TextStyle(
                              color: balanceColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'myfont',
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
