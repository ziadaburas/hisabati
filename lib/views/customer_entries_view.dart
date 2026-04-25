import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../controllers/entries_controller.dart';
import '../models/entry_model.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_header.dart';
import '../widgets/card_entry.dart';
import 'add_entry_view.dart';

class CustomerEntriesView extends StatelessWidget {
  final String customerName;

  const CustomerEntriesView({super.key, required this.customerName});

  @override
  Widget build(BuildContext context) {
    final entriesController = Get.find<EntriesController>();
    final amountFormatter = NumberFormat('#,##0', 'en_US');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        body: Obx(() {
          final entries = entriesController.getCustomerEntries(customerName);

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
              // ===== هيدر مشابه للرئيسية =====
              _buildHeader(
                context,
                customerName,
                totalCredit,
                totalDebit,
                balance,
                isPositive,
                amountFormatter,
                entries,
                isDark,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'القيود (${entries.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF37474F),
                        fontFamily: 'myfont',
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
                                size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد قيود لهذا العميل',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade500,
                                fontFamily: 'myfont',
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
                entriesController.entries[index],
                index == 0 ?null : entriesController.entries[index-1],
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
          backgroundColor: AppColors.primaryMedium,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String customerName,
    double totalCredit,
    double totalDebit,
    double balance,
    bool isPositive,
    NumberFormat amountFormatter,
    List<EntryModel> entries,
    bool isDark,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryMedium, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x330F3D2E),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row - اسم العميل مع الأزرار
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              child: Row(
                children: [
                  // زر الرجوع
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  // أفاتار العميل
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      customerName.isNotEmpty
                          ? customerName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'myfont',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // اسم العميل
                  Expanded(
                    child: Text(
                      customerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        fontFamily: 'myfont',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // زر المشاركة PDF
                  IconButton(
                    onPressed: () => _shareCustomerPdf(entries, customerName),
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    tooltip: 'مشاركة تقرير PDF',
                  ),
                ],
              ),
            ),
            // شريط الإحصائيات - مثل الرئيسية
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child:  BalanceHeader(
                totalCredit: totalCredit,
                totalDebit: totalDebit,
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, Color color, IconData icon, NumberFormat formatter) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 14),
        const SizedBox(height: 4),
        Text(
          formatter.format(amount),
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

  Future<void> _shareCustomerPdf(List<EntryModel> entries, String customerName) async {
    if (entries.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد قيود لمشاركتها',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    try {
      Get.snackbar(
        'جاري التحضير',
        'يتم إنشاء تقرير PDF...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryDark,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );

      final pdfBytes = await PdfService.generateReport(
        entries: entries,
        reportTitle: 'تقرير العميل: $customerName',
        customerName: customerName,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'حساباتي_${customerName}_${DateTime.now()}.pdf',
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إنشاء التقرير: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }
 Widget _buildEntryTile(
    EntryModel entry,
    EntryModel? lastEntry

  ) {
    final currentItem = entry;
    bool showDateHeader = false;
    final entriesController = Get.find<EntriesController>();

    if (lastEntry == null) {
      showDateHeader = true;
    } else {
      final previousItem = lastEntry;
      if (currentItem.date.toString().split(" ").first != previousItem.date.toString().split(" ").first) {
        showDateHeader = true;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showDateHeader)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Text(
                currentItem.date.toString().split(" ").first,
                textAlign: ui.TextAlign.left,
                style:const TextStyle( fontWeight: FontWeight.bold),
              ),
          ),
          CardEntryTile(
            entry: entry,
            onDelete: () => entriesController.confirmDelete(entry),
            onTap: () => Get.to(() => AddEntryView(editEntry: entry))
            )
    
      
      ]
    );
  }
 
}
