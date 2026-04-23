import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/entries_controller.dart';
import '../../models/entry_model.dart';
import '../add_entry/add_entry_view.dart';

class CustomerEntriesView extends StatelessWidget {
  final String customerName;

  const CustomerEntriesView({super.key, required this.customerName});

  @override
  Widget build(BuildContext context) {
    final entriesController = Get.find<EntriesController>();
    final authController = Get.find<AuthController>();
    final amountFormatter = NumberFormat('#,##0', 'en_US');
    final dateFormatter = DateFormat('dd/MM/yyyy', 'en_US');

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity( 0.2),
                child: Text(
                  customerName.isNotEmpty
                      ? customerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          final entries =
              entriesController.getCustomerEntries(customerName);

          double totalCredit = 0;
          double totalDebit = 0;
          for (final entry in entries) {
            if (entry.isCredit) {
              totalCredit += entry.amount;
            } else {
              totalDebit += entry.amount;
            }
          }
          final balance = totalCredit - totalDebit;
          final isPositive = balance >= 0;

          return Column(
            children: [
              // Summary Header
              Container(
                width: double.infinity,
                color: const Color(0xFF1565C0),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity( 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'لي',
                            amountFormatter.format(totalCredit),
                            const Color(0xFF4CAF50),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity( 0.3),
                          ),
                          _buildSummaryItem(
                            'عليا',
                            amountFormatter.format(totalDebit),
                            const Color(0xFFEF5350),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity( 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'صافي الرصيد',
                              style: TextStyle(
                                color: Colors.white.withOpacity( 0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isPositive
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: isPositive
                                      ? const Color(0xFF81C784)
                                      : const Color(0xFFEF9A9A),
                                  size: 22,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  amountFormatter.format(balance.abs()),
                                  style: TextStyle(
                                    color: isPositive
                                        ? const Color(0xFF81C784)
                                        : const Color(0xFFEF9A9A),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              isPositive ? 'لي' : 'عليا',
                              style: TextStyle(
                                color: isPositive
                                    ? const Color(0xFF81C784)
                                    : const Color(0xFFEF9A9A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'القيود (${entries.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد قيود لهذا العميل',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          return _buildEntryTile(
                            context,
                            entries[index],
                            amountFormatter,
                            dateFormatter,
                            entriesController,
                            authController,
                          );
                        },
                      ),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(
              () => AddEntryView(presetCustomerName: customerName)),
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity( 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEntryTile(
    BuildContext context,
    EntryModel entry,
    NumberFormat amountFormatter,
    DateFormat dateFormatter,
    EntriesController entriesController,
    AuthController authController,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => AddEntryView(editEntry: entry)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              right: BorderSide(
                color: entry.isCredit
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.isCredit
                      ? const Color(0xFF4CAF50).withOpacity( 0.1)
                      : const Color(0xFFEF5350).withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  entry.isCredit
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: entry.isCredit
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                  size: 22,
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
                          entry.isCredit ? 'لي' : 'عليا',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: entry.isCredit
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF5350),
                          ),
                        ),
                        Text(
                          '${entry.isCredit ? '+' : '-'}${amountFormatter.format(entry.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: entry.isCredit
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF5350),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatter.format(entry.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (entry.note.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.note_rounded,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.note,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Delete button
              IconButton(
                onPressed: () => _confirmDelete(
                    context, entry, entriesController, authController),
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade300, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, EntryModel entry,
      EntriesController controller, AuthController authController) {
    Get.defaultDialog(
      title: 'حذف القيد',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText:
          'هل أنت متأكد من حذف هذا القيد؟\n\n${entry.isCredit ? "لي" : "عليا"} - ${entry.amount}',
      textConfirm: 'حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: const Color(0xFF1565C0),
      onConfirm: () {
        final userId = authController.user.value?.uid;
        if (userId != null) {
          controller.deleteEntry(userId, entry.id);
          Get.back();
          Get.snackbar(
            'تم الحذف',
            'تم حذف القيد بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      },
    );
  }
}
