import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/entries_controller.dart';
import '../../models/entry_model.dart';
import '../../theme/app_theme.dart';
import '../add_entry/add_entry_view.dart';

class EntriesView extends StatelessWidget {
   EntriesView({super.key});
  var isDark = false;
  final amountFormatter = NumberFormat('#,##0', 'en_US');
    final dateFormatter = DateFormat('dd/MM/yyyy', 'en_US');

  @override
  Widget build(BuildContext context) {
    final entriesController = Get.find<EntriesController>();
    final authController = Get.find<AuthController>();
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Obx(() {
        if (entriesController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryMedium,
            ),
          );
        }

        if (entriesController.entries.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primaryMedium,
          onRefresh: () async {
            final userId = authController.user.value?.uid;
            if (userId != null) {
              await entriesController.loadEntries(userId);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: entriesController.entries.length,
            itemBuilder: (context, index) {
              return _buildEntryTile(
                context,
                entriesController.entries[index],
                entriesController,
                authController,
                index == 0 ?null : entriesController.entries[index-1],
              );
            },
          ),
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
              Icons.receipt_long_rounded,
              size: 44,
              color: AppColors.primaryDark.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'لا توجد قيود بعد',
            style: TextStyle(
              fontSize: 17,
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w600,
              fontFamily: 'myfont',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اضغط على (+) لإضافة قيد جديد',
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
   Widget _buildEntryTile(
    BuildContext context,
    EntryModel entry,
    EntriesController entriesController,
    AuthController authController,
    EntryModel? lastEntry

  ) {
    final currentItem = entry;
    
    // متغير لتحديد هل نظهر الفاصل الزمني أم لا
    bool showDateHeader = false;

    // إذا كان هذا أول عنصر في القائمة، نظهر التاريخ دائماً
    if (lastEntry == null) {
      showDateHeader = true;
    } else {
      // نقارن تاريخ العنصر الحالي بالعنصر الذي قبله
      final previousItem = lastEntry;
      
      // ملاحظة: تأكد من مقارنة التاريخ فقط (يوم/شهر/سنة) بدون الوقت
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
    
     Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isDark ? 0 : 1,
      color: isDark ? AppColors.darkCard : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? BorderSide(color: AppColors.darkDivider) : BorderSide.none,
      ),
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
                    ? AppColors.success
                    : AppColors.error,
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
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  entry.isCredit
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: entry.isCredit
                      ? AppColors.success
                      : AppColors.error,
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
                           entry.customerName.isNotEmpty
                                ? entry.customerName
                                : 'بدون اسم',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'myfont',
                            color: entry.isCredit
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        Text(
                          '${entry.isCredit ? '+' : '-'}${amountFormatter.format(entry.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'myfont',
                            color: entry.isCredit
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatter.format(entry.date),
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'myfont',
                            color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade500,
                          ),
                        ),
                        if (entry.note.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.note_rounded,
                              size: 12, color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.note,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'myfont',
                                color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade500,
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
              IconButton(
                onPressed: () => _confirmDelete(
                    context, entry, entriesController, authController,),
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade300, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    )
      ]
    );
  }


  Widget _buildEntryCard(
    BuildContext context,
    EntryModel entry,
    EntriesController controller,
    AuthController authController,
  ) {
    final dateFormatter = DateFormat('dd/MM/yyyy', 'en_US');
    final amountFormatter = NumberFormat('#,##0.##', 'en_US');
    final isCredit = entry.isCredit;
    final color = isCredit ? const ui.Color.fromRGBO(34, 197, 94, 1) : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.cardShadow,
        border: Border(
          right: BorderSide(color: color, width: 4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.to(() => AddEntryView(editEntry: entry)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isCredit
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.customerName.isNotEmpty
                                ? entry.customerName
                                : 'بدون اسم',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'myfont',
                              color: entry.customerName.isNotEmpty
                                  ? AppColors.textPrimary
                                  : AppColors.mediumGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${isCredit ? '+' : '-'}${amountFormatter.format(entry.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'myfont',
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: AppColors.mediumGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatter.format(entry.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGray,
                            fontFamily: 'myfont',
                          ),
                        ),
                        if (entry.note.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.notes_rounded,
                            size: 12,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.note,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                                fontFamily: 'myfont',
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
              // Delete Button
              IconButton(
                onPressed: () => _confirmDelete(
                    context, entry, controller, authController),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error.withOpacity(0.6),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
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
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'myfont',
        color: isDark ? AppColors.darkTextPrimary : null,
      ),
      middleText:
          'هل أنت متأكد من حذف هذا القيد؟\n\n${entry.isCredit ? "لي" : "عليا"} - ${entry.amount}',
      middleTextStyle: TextStyle(
        fontFamily: 'myfont',
        color: isDark ? AppColors.darkTextSecondary : null,
      ),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      textConfirm: 'حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: AppColors.primaryMedium,
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

  void _confirmDelete1(
    BuildContext context,
    EntryModel entry,
    EntriesController controller,
    AuthController authController,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.delete_rounded, color: AppColors.error, size: 22),
              SizedBox(width: 8),
              Text(
                'حذف القيد',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  fontFamily: 'myfont',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'هل أنت متأكد من حذف هذا القيد؟',
                style: TextStyle(fontSize: 14, fontFamily: 'myfont'),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: entry.isCredit ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${entry.customerName.isNotEmpty ? entry.customerName : "بدون اسم"} - ${entry.amount}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'myfont',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: AppColors.mediumGray,
                  fontFamily: 'myfont',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                final userId = authController.user.value?.uid;
                if (userId != null) {
                  controller.deleteEntry(userId, entry.id);
                  Get.snackbar(
                    'تم الحذف',
                    'تم حذف القيد بنجاح',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primaryDark,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(12),
                    borderRadius: 12,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('حذف', style: TextStyle(fontFamily: 'myfont')),
            ),
          ],
        ),
      ),
    );
  }
}
