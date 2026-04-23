import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/entry_model.dart';
import '../services/excel_service.dart';
import 'auth_controller.dart';
import 'entries_controller.dart';

enum ExportFilterType { all, customer, period, customerPeriod }

class ImportExportController extends GetxController {
  // حالة التصدير
  final Rx<ExportFilterType> exportFilterType = ExportFilterType.all.obs;
  final RxString selectedCustomer = ''.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxBool isExporting = false.obs;
  final RxBool isImporting = false.obs;

  // نتيجة الاستيراد
  final RxInt importedCount = 0.obs;
  final RxList<String> importErrors = <String>[].obs;
  final RxBool showImportResult = false.obs;

  List<String> get availableCustomers =>
      Get.find<EntriesController>().customerNames;

  List<EntryModel> get filteredEntries {
    final allEntries = Get.find<EntriesController>().entries;
    List<EntryModel> filtered = List.from(allEntries);

    if ((exportFilterType.value == ExportFilterType.customer ||
            exportFilterType.value == ExportFilterType.customerPeriod) &&
        selectedCustomer.value.isNotEmpty) {
      filtered = filtered
          .where((e) => e.customerName == selectedCustomer.value)
          .toList();
    }

    if (exportFilterType.value == ExportFilterType.period ||
        exportFilterType.value == ExportFilterType.customerPeriod) {
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

  String get exportFileName {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    switch (exportFilterType.value) {
      case ExportFilterType.all:
        return 'حساباتي_كل_القيود_$dateStr.xlsx';
      case ExportFilterType.customer:
        return 'حساباتي_${selectedCustomer.value}_$dateStr.xlsx';
      case ExportFilterType.period:
        return 'حساباتي_فترة_$dateStr.xlsx';
      case ExportFilterType.customerPeriod:
        return 'حساباتي_${selectedCustomer.value}_فترة_$dateStr.xlsx';
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          fromDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1565C0),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) fromDate.value = picked;
  }

  Future<void> selectToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1565C0),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) toDate.value = picked;
  }

  /// تصدير للموبايل - يستخدم FilePicker
  Future<void> exportToExcelMobile() async {
    final entries = filteredEntries;
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

    isExporting.value = true;
    try {
      final bytes = await ExcelService.exportEntries(entries: entries);
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

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ ملف Excel',
        fileName: exportFileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        bytes: bytes,
      );

      if (savePath != null) {
        Get.snackbar(
          'تم التصدير بنجاح',
          'تم حفظ الملف:\n$savePath',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Export error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء التصدير',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }

  /// توليد bytes للتصدير (مشترك بين الويب والموبايل)
  Future<Uint8List?> generateExcelBytes() async {
    return await ExcelService.exportEntries(entries: filteredEntries);
  }

  Future<void> importFromExcel() async {
    isImporting.value = true;
    showImportResult.value = false;
    importErrors.clear();
    importedCount.value = 0;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        isImporting.value = false;
        return;
      }

      final file = result.files.first;
      if (file.bytes == null) {
        Get.snackbar(
          'خطأ',
          'لم يتم قراءة الملف بشكل صحيح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isImporting.value = false;
        return;
      }

      final importResult = await ExcelService.importEntries(file.bytes!);

      if (importResult.successCount == 0 && importResult.hasErrors) {
        importErrors.assignAll(importResult.errors);
        showImportResult.value = true;
        isImporting.value = false;
        return;
      }

      // أضف القيود إلى قاعدة البيانات
      final authController = Get.find<AuthController>();
      final entriesController = Get.find<EntriesController>();
      final userId = authController.user.value?.uid;

      if (userId == null) {
        Get.snackbar(
          'خطأ',
          'يجب تسجيل الدخول أولاً',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isImporting.value = false;
        return;
      }

      int added = 0;
      int failed = 0;
      for (final entry in importResult.entries) {
        try {
          final success = await entriesController.addEntry(userId, entry);
          if (success) {
            added++;
          } else {
            failed++;
          }
        } catch (e) {
          failed++;
        }
      }

      importedCount.value = added;
      importErrors.assignAll(importResult.errors);
      if (failed > 0) {
        importErrors.add('فشل إضافة $failed قيد');
      }
      showImportResult.value = true;

      if (added > 0) {
        Get.snackbar(
          'تم الاستيراد بنجاح',
          'تم إضافة $added قيد من الملف',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Import error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الاستيراد: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isImporting.value = false;
    }
  }

  void resetFilters() {
    exportFilterType.value = ExportFilterType.all;
    selectedCustomer.value = '';
    fromDate.value = null;
    toDate.value = null;
  }

  void resetImportResult() {
    showImportResult.value = false;
    importErrors.clear();
    importedCount.value = 0;
  }
}
