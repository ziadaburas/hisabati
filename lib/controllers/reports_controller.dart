import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../models/entry_model.dart';
import '../services/pdf_service.dart';
import 'entries_controller.dart';

enum ReportType { all, customer, period, customerPeriod }

class ReportsController extends GetxController {
  final Rx<ReportType> reportType = ReportType.all.obs;
  final RxString selectedCustomer = ''.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxBool isGenerating = false.obs;

  List<String> get availableCustomers =>
      Get.find<EntriesController>().customerNames;

  List<EntryModel> get filteredEntries {
    final allEntries = Get.find<EntriesController>().entries;
    List<EntryModel> filtered = List.from(allEntries);

    // Filter by customer
    if ((reportType.value == ReportType.customer ||
            reportType.value == ReportType.customerPeriod) &&
        selectedCustomer.value.isNotEmpty) {
      filtered = filtered
          .where((e) => e.customerName == selectedCustomer.value)
          .toList();
    }

    // Filter by date
    if (reportType.value == ReportType.period ||
        reportType.value == ReportType.customerPeriod) {
      if (fromDate.value != null) {
        filtered = filtered
            .where((e) => !e.date.isBefore(fromDate.value!))
            .toList();
      }
      if (toDate.value != null) {
        final endOfDay = DateTime(
          toDate.value!.year,
          toDate.value!.month,
          toDate.value!.day,
          23,
          59,
          59,
        );
        filtered =
            filtered.where((e) => !e.date.isAfter(endOfDay)).toList();
      }
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  String get reportTitle {
    switch (reportType.value) {
      case ReportType.all:
        return 'All Entries Report';
      case ReportType.customer:
        return 'Customer Report: ${selectedCustomer.value}';
      case ReportType.period:
        return 'Period Report';
      case ReportType.customerPeriod:
        return 'Customer Period Report: ${selectedCustomer.value}';
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      fromDate.value = picked;
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      toDate.value = picked;
    }
  }

  Future<void> generateAndPrintPdf() async {
    isGenerating.value = true;
    try {
      final entries = filteredEntries;
      if (entries.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'لا توجد قيود مطابقة للفلتر المحدد',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isGenerating.value = false;
        return;
      }

      final pdfBytes = await PdfService.generateReport(
        entries: entries,
        reportTitle: reportTitle,
        customerName: selectedCustomer.value.isNotEmpty
            ? selectedCustomer.value
            : null,
        fromDate: fromDate.value,
        toDate: toDate.value,
      );

      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
        name: 'OwnAccounts_Report',
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل توليد التقرير: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isGenerating.value = false;
  }

  void resetFilters() {
    reportType.value = ReportType.all;
    selectedCustomer.value = '';
    fromDate.value = null;
    toDate.value = null;
  }
}
