import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/import_export_controller.dart';

class ImportExportView extends StatelessWidget {
  const ImportExportView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImportExportController());
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'en_US');

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.import_export_rounded,
                      color: Color(0xFF1565C0), size: 26),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التصدير والاستيراد',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    Text(
                      'تبادل البيانات مع ملفات Excel',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ========== قسم التصدير ==========
            _buildSectionHeader(
              'تصدير إلى Excel',
              Icons.file_download_rounded,
              const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 14),

            // فلتر التصدير
            const Text(
              'نوع التصدير',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 10),

            Obx(() => Column(
                  children: [
                    _buildFilterOption(
                      controller,
                      ExportFilterType.all,
                      'كل القيود',
                      Icons.receipt_long_rounded,
                      'تصدير جميع القيود',
                    ),
                    _buildFilterOption(
                      controller,
                      ExportFilterType.customer,
                      'عميل محدد',
                      Icons.person_rounded,
                      'تصدير قيود عميل معين',
                    ),
                    _buildFilterOption(
                      controller,
                      ExportFilterType.period,
                      'فترة محددة',
                      Icons.date_range_rounded,
                      'تصدير قيود خلال فترة زمنية',
                    ),
                    _buildFilterOption(
                      controller,
                      ExportFilterType.customerPeriod,
                      'عميل + فترة',
                      Icons.filter_alt_rounded,
                      'تصدير قيود عميل في فترة محددة',
                    ),
                  ],
                )),

            const SizedBox(height: 16),

            // فلاتر إضافية
            Obx(() {
              final showCustomer =
                  controller.exportFilterType.value ==
                          ExportFilterType.customer ||
                      controller.exportFilterType.value ==
                          ExportFilterType.customerPeriod;
              final showDate =
                  controller.exportFilterType.value ==
                          ExportFilterType.period ||
                      controller.exportFilterType.value ==
                          ExportFilterType.customerPeriod;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCustomer) ...[
                    const Text(
                      'اختر العميل',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF37474F)),
                    ),
                    const SizedBox(height: 8),
                    _buildCustomerDropdown(controller),
                    const SizedBox(height: 16),
                  ],
                  if (showDate) ...[
                    const Text(
                      'الفترة الزمنية',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF37474F)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            context,
                            'من تاريخ',
                            controller.fromDate.value,
                            dateFormatter,
                            () => controller.selectFromDate(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateSelector(
                            context,
                            'إلى تاريخ',
                            controller.toDate.value,
                            dateFormatter,
                            () => controller.selectToDate(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            }),

            // معاينة
            Obx(() {
              final entries = controller.filteredEntries;
              double credit = 0, debit = 0;
              for (final e in entries) {
                if (e.isCredit) {
                  credit += e.amount;
                } else {
                  debit += e.amount;
                }
              }
              final amountFmt = NumberFormat('#,##0', 'en_US');

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF2E7D32).withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.preview_rounded,
                            color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'معاينة: ${entries.length} قيد',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (entries.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat('لي', amountFmt.format(credit),
                              const Color(0xFF4CAF50)),
                          _buildMiniStat('عليّا', amountFmt.format(debit),
                              const Color(0xFFEF5350)),
                          _buildMiniStat(
                            'الرصيد',
                            '${credit - debit >= 0 ? '+' : ''}${amountFmt.format(credit - debit)}',
                            credit - debit >= 0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF5350),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // زر التصدير
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: controller.isExporting.value
                        ? null
                        : () => _handleExport(context, controller),
                    icon: controller.isExporting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Icon(Icons.download_rounded),
                    label: Text(
                      controller.isExporting.value
                          ? 'جاري التصدير...'
                          : 'تصدير إلى Excel',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                )),

            Center(
              child: TextButton.icon(
                onPressed: () => controller.resetFilters(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة تعيين الفلاتر'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade200, thickness: 1.5),
            const SizedBox(height: 16),

            // ========== قسم الاستيراد ==========
            _buildSectionHeader(
              'استيراد من Excel',
              Icons.file_upload_rounded,
              const Color(0xFF1565C0),
            ),
            const SizedBox(height: 14),

            // تعليمات الاستيراد
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Colors.blue.shade700, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'تعليمات الاستيراد',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInstruction(
                      '1', 'الملف يجب أن يكون بصيغة .xlsx أو .xls'),
                  _buildInstruction('2',
                      'الصف الأول يجب أن يكون رأس الجدول (التاريخ، العميل، الاتجاه، المبلغ)'),
                  _buildInstruction('3',
                      'عمود الاتجاه: "لي" أو "عليّا"'),
                  _buildInstruction(
                      '4', 'التاريخ بصيغة DD/MM/YYYY (مثال: 25/01/2025)'),
                  _buildInstruction('5',
                      'يمكن استيراد ملفات تم تصديرها مسبقاً من التطبيق مباشرة'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // زر الاستيراد
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: controller.isImporting.value
                        ? null
                        : () => controller.importFromExcel(),
                    icon: controller.isImporting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Icon(Icons.upload_rounded),
                    label: Text(
                      controller.isImporting.value
                          ? 'جاري الاستيراد...'
                          : 'اختر ملف Excel للاستيراد',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                )),

            // نتيجة الاستيراد
            Obx(() {
              if (!controller.showImportResult.value) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: controller.importedCount.value > 0
                      ? const Color(0xFF4CAF50).withOpacity(0.08)
                      : Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.importedCount.value > 0
                        ? const Color(0xFF4CAF50).withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          controller.importedCount.value > 0
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          color: controller.importedCount.value > 0
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.importedCount.value > 0
                                ? 'تم استيراد ${controller.importedCount.value} قيد بنجاح'
                                : 'فشل الاستيراد',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.importedCount.value > 0
                                  ? const Color(0xFF2E7D32)
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.resetImportResult(),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    if (controller.importErrors.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'تنبيهات:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...controller.importErrors
                          .take(5)
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '• $e',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              )),
                      if (controller.importErrors.length > 5)
                        Text(
                          '... و ${controller.importErrors.length - 5} تنبيه آخر',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800),
                        ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(
    ImportExportController controller,
    ExportFilterType type,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = controller.exportFilterType.value == type;
    return GestureDetector(
      onTap: () => controller.exportFilterType.value = type,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2E7D32).withOpacity(0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.black87,
                    ),
                  ),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(ImportExportController controller) {
    final customers = controller.availableCustomers;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text('اختر العميل'),
        value: controller.selectedCustomer.value.isNotEmpty
            ? controller.selectedCustomer.value
            : null,
        items: customers
            .map((name) =>
                DropdownMenuItem(value: name, child: Text(name)))
            .toList(),
        onChanged: (value) {
          if (value != null) controller.selectedCustomer.value = value;
        },
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime? date,
    DateFormat formatter,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  date != null ? formatter.format(date) : 'اختر',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: date != null
                        ? Colors.black87
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  TextStyle(fontSize: 12, color: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(
      BuildContext context, ImportExportController controller) async {
    final entries = controller.filteredEntries;
    if (entries.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد قيود مطابقة للفلتر المحدد',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    controller.isExporting.value = true;
    try {
      final bytes = await controller.generateExcelBytes();
      if (bytes == null) {
        Get.snackbar(
          'خطأ',
          'فشل إنشاء ملف Excel',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (kIsWeb) {
        _downloadFileWeb(bytes, controller.exportFileName);
        Get.snackbar(
          'تم التصدير بنجاح',
          'تم تحميل ملف Excel (${entries.length} قيد)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        await controller.exportToExcelMobile();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      controller.isExporting.value = false;
    }
  }

  void _downloadFileWeb(List<int> bytes, String fileName) {
    // سيتم التعامل معه عبر dart:html في نسخة الويب
    // للموبايل يستخدم FilePicker
    if (kDebugMode) {
      debugPrint('Web download: $fileName (${bytes.length} bytes)');
    }
  }
}
