import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/reports_controller.dart';
import '../../controllers/entries_controller.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'en_US');
    final amountFormatter = NumberFormat('#,##0', 'en_US');

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'التقارير',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'قم بتوليد تقارير PDF حسب الحاجة',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Report Type Selection
            const Text(
              'نوع التقرير',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Column(
                  children: [
                    _buildReportTypeOption(
                      controller,
                      ReportType.all,
                      'كل القيود',
                      Icons.receipt_long_rounded,
                      'تقرير شامل لجميع القيود',
                    ),
                    _buildReportTypeOption(
                      controller,
                      ReportType.customer,
                      'عميل محدد',
                      Icons.person_rounded,
                      'تقرير قيود عميل معين',
                    ),
                    _buildReportTypeOption(
                      controller,
                      ReportType.period,
                      'فترة محددة',
                      Icons.date_range_rounded,
                      'تقرير قيود خلال فترة زمنية',
                    ),
                    _buildReportTypeOption(
                      controller,
                      ReportType.customerPeriod,
                      'عميل + فترة',
                      Icons.filter_alt_rounded,
                      'تقرير عميل خلال فترة محددة',
                    ),
                  ],
                )),

            const SizedBox(height: 20),

            // Filters based on report type
            Obx(() {
              final showCustomer =
                  controller.reportType.value == ReportType.customer ||
                      controller.reportType.value == ReportType.customerPeriod;
              final showDate =
                  controller.reportType.value == ReportType.period ||
                      controller.reportType.value == ReportType.customerPeriod;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCustomer) ...[
                    const Text(
                      'اختر العميل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCustomerDropdown(controller),
                    const SizedBox(height: 20),
                  ],
                  if (showDate) ...[
                    const Text(
                      'الفترة الزمنية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                  ],
                ],
              );
            }),

            // Preview of entries count and summary
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
              final balance = credit - debit;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity( 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.preview_rounded,
                            color: Color(0xFF1565C0)),
                        const SizedBox(width: 8),
                        const Text(
                          'معاينة التقرير',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0)
                                .withOpacity( 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${entries.length} قيد',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPreviewItem(
                            'لي',
                            amountFormatter.format(credit),
                            const Color(0xFF4CAF50),
                          ),
                        ),
                        Expanded(
                          child: _buildPreviewItem(
                            'عليّا',
                            amountFormatter.format(debit),
                            const Color(0xFFEF5350),
                          ),
                        ),
                        Expanded(
                          child: _buildPreviewItem(
                            'الرصيد',
                            '${balance >= 0 ? "+" : ""}${amountFormatter.format(balance)}',
                            balance >= 0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF5350),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Generate PDF Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isGenerating.value
                        ? null
                        : () => controller.generateAndPrintPdf(),
                    icon: controller.isGenerating.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded),
                    label: Text(
                      controller.isGenerating.value
                          ? 'جاري توليد التقرير...'
                          : 'توليد وطباعة PDF',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  )),
            ),

            const SizedBox(height: 12),

            // Reset Filters
            Center(
              child: TextButton.icon(
                onPressed: () => controller.resetFilters(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة تعيين الفلاتر'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeOption(
    ReportsController controller,
    ReportType type,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = controller.reportType.value == type;
    return GestureDetector(
      onTap: () => controller.reportType.value = type,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1565C0).withOpacity( 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1565C0)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1565C0).withOpacity( 0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF1565C0)
                    : Colors.grey.shade500,
                size: 22,
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
                      fontSize: 15,
                      color: isSelected
                          ? const Color(0xFF1565C0)
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF1565C0), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(ReportsController controller) {
    final customers = Get.find<EntriesController>().customerNames;
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
          if (value != null) {
            controller.selectedCustomer.value = value;
          }
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
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
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
                    color: date != null ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
