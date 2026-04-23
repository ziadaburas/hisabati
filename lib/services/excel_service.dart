import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/entry_model.dart';

class ExcelService {
  static const _dateFormat = 'dd/MM/yyyy HH:mm';

  /// تصدير القيود إلى ملف Excel
  static Future<Uint8List?> exportEntries({
    required List<EntryModel> entries,
    String? sheetTitle,
  }) async {
    try {
      
      final excel = Excel.createExcel();
      final sheetName = sheetTitle ?? 'القيود';

      // 1. جلب اسم الشيت الافتراضي (غالباً Sheet1)
      final defaultSheet = excel.getDefaultSheet();
      
      // 2. إعادة تسمية الشيت الافتراضي بدلاً من إنشاء واحد جديد
      if (defaultSheet != null) {
        excel.rename(defaultSheet, sheetName);
      }

      // 3. تحديد الشيت للعمل عليه
      final sheet = excel[sheetName];
      // ضبط اتجاه الشيت من اليمين لليسار
      // رأس الجدول
      final headers = [
        'رقم',
        'التاريخ',
        'اسم العميل',
        'الاتجاه',
        'المبلغ',
        'الملاحظة',
        'تاريخ الإنشاء',
      ];

      // تنسيق الرأس
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1565C0'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText,
      );

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // ضبط عرض الأعمدة
      sheet.setColumnWidth(0, 6);  // رقم
      sheet.setColumnWidth(1, 14); // التاريخ
      sheet.setColumnWidth(2, 20); // اسم العميل
      sheet.setColumnWidth(3, 12); // الاتجاه
      sheet.setColumnWidth(4, 14); // المبلغ
      sheet.setColumnWidth(5, 30); // الملاحظة
      sheet.setColumnWidth(6, 20); // تاريخ الإنشاء

      final dateFormatter = DateFormat(_dateFormat, 'en_US');
      final sortedEntries = List<EntryModel>.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));

      // أنماط الصفوف
      final creditStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#2E7D32'),
        horizontalAlign: HorizontalAlign.Center,
      );
      final debitStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#C62828'),
        horizontalAlign: HorizontalAlign.Center,
      );
      final evenRowStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F3F4F6'),
      );

      for (int i = 0; i < sortedEntries.length; i++) {
        final entry = sortedEntries[i];
        final rowIndex = i + 1;
        final isCredit = entry.isCredit;
        final isEvenRow = i % 2 == 1;

        // رقم
        final numCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 0, rowIndex: rowIndex));
        numCell.value = IntCellValue(i + 1);
        if (isEvenRow) numCell.cellStyle = evenRowStyle;

        // التاريخ
        final dateCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 1, rowIndex: rowIndex));
        dateCell.value = TextCellValue(dateFormatter.format(entry.date));
        if (isEvenRow) dateCell.cellStyle = evenRowStyle;

        // اسم العميل
        final customerCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 2, rowIndex: rowIndex));
        customerCell.value = TextCellValue(
            entry.customerName.isEmpty ? '-' : entry.customerName);
        if (isEvenRow) customerCell.cellStyle = evenRowStyle;

        // الاتجاه (له / عليه)
        final dirCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 3, rowIndex: rowIndex));
        dirCell.value = TextCellValue(isCredit ? 'لي' : 'عليّا');
        dirCell.cellStyle = isCredit ? creditStyle : debitStyle;

        // المبلغ
        final amountCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 4, rowIndex: rowIndex));
        amountCell.value = IntCellValue(entry.amount);
        amountCell.cellStyle = CellStyle(
          fontColorHex: isCredit
              ? ExcelColor.fromHexString('#2E7D32')
              : ExcelColor.fromHexString('#C62828'),
          horizontalAlign: HorizontalAlign.Center,
          backgroundColorHex: isEvenRow
              ? ExcelColor.fromHexString('#F3F4F6')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

        // الملاحظة
        final noteCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 5, rowIndex: rowIndex));
        noteCell.value = TextCellValue(entry.note.isEmpty ? '-' : entry.note);
        if (isEvenRow) noteCell.cellStyle = evenRowStyle;

        // تاريخ الإنشاء
        final createdCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 6, rowIndex: rowIndex));
        createdCell.value =
            TextCellValue(dateFormatter.format(entry.createdAt));
        if (isEvenRow) createdCell.cellStyle = evenRowStyle;
      }

      // صف الإجمالي
      if (sortedEntries.isNotEmpty) {
        final totalRow = sortedEntries.length + 1;
        double totalCredit = 0;
        double totalDebit = 0;
        for (final e in sortedEntries) {
          if (e.isCredit) {
            totalCredit += e.amount;
          } else {
            totalDebit += e.amount;
          }
        }

        final totalStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#E3F2FD'),
        );

        final totalLabelCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 0, rowIndex: totalRow));
        totalLabelCell.value = TextCellValue('الإجمالي');
        totalLabelCell.cellStyle = totalStyle;

        // إجمالي له
        final totalCreditCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 3, rowIndex: totalRow));
        totalCreditCell.value =
            TextCellValue('لي: ${totalCredit.toInt()}');
        totalCreditCell.cellStyle = CellStyle(
          bold: true,
          fontColorHex: ExcelColor.fromHexString('#2E7D32'),
          backgroundColorHex: ExcelColor.fromHexString('#E8F5E9'),
        );

        // إجمالي عليه
        final totalDebitCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 4, rowIndex: totalRow));
        totalDebitCell.value =
            TextCellValue('عليّا: ${totalDebit.toInt()}');
        totalDebitCell.cellStyle = CellStyle(
          bold: true,
          fontColorHex: ExcelColor.fromHexString('#C62828'),
          backgroundColorHex: ExcelColor.fromHexString('#FFEBEE'),
        );

        // الرصيد
        final balanceCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: 5, rowIndex: totalRow));
        final balance = totalCredit - totalDebit;
        balanceCell.value =
            TextCellValue('الرصيد: ${balance >= 0 ? '+' : ''}${balance.toInt()}');
        balanceCell.cellStyle = CellStyle(
          bold: true,
          fontColorHex: balance >= 0
              ? ExcelColor.fromHexString('#2E7D32')
              : ExcelColor.fromHexString('#C62828'),
          backgroundColorHex: ExcelColor.fromHexString('#E3F2FD'),
        );
      }

      final bytes = excel.encode();
      if (bytes == null) return null;
      return Uint8List.fromList(bytes);
    } catch (e) {
      if (kDebugMode) debugPrint('Excel export error: $e');
      return null;
    }
  }

  /// استيراد القيود من ملف Excel
  static Future<ExcelImportResult> importEntries(Uint8List fileBytes) async {
    final errors = <String>[];
    final entries = <EntryModel>[];

    try {
      final excel = Excel.decodeBytes(fileBytes);

      // ابحث عن أول شيت
      if (excel.tables.isEmpty) {
        return ExcelImportResult(
          entries: [],
          errors: ['لم يتم العثور على بيانات في الملف'],
          successCount: 0,
        );
      }

      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;

      if (sheet.rows.isEmpty) {
        return ExcelImportResult(
          entries: [],
          errors: ['الملف فارغ'],
          successCount: 0,
        );
      }

      // تحقق من صحة الرأس
      final headerRow = sheet.rows.first;
      final headers = headerRow
          .map((cell) => cell?.value?.toString().trim() ?? '')
          .toList();

      // نتحقق من أن الملف له الأعمدة الأساسية (التاريخ، الاتجاه، المبلغ)
      bool hasDate = headers.any((h) => h.contains('التاريخ'));
      bool hasDirection =
          headers.any((h) => h.contains('الاتجاه') || h.contains('له') || h.contains('عليه'));
      bool hasAmount = headers.any((h) => h.contains('المبلغ'));

      if (!hasDate || !hasAmount) {
        return ExcelImportResult(
          entries: [],
          errors: [
            'تنسيق الملف غير صحيح. يجب أن يحتوي على أعمدة: التاريخ، المبلغ، الاتجاه'
          ],
          successCount: 0,
        );
      }

      // مؤشرات الأعمدة
      int dateCol = headers.indexWhere((h) => h.contains('التاريخ') && !h.contains('الإنشاء'));
      int customerCol = headers.indexWhere((h) => h.contains('العميل'));
      int directionCol = headers.indexWhere((h) => h.contains('الاتجاه'));
      int amountCol = headers.indexWhere((h) => h.contains('المبلغ'));
      int noteCol = headers.indexWhere((h) => h.contains('الملاحظة'));

      if (dateCol == -1) dateCol = 1;
      if (customerCol == -1) customerCol = 2;
      if (directionCol == -1) directionCol = 3;
      if (amountCol == -1) amountCol = 4;
      if (noteCol == -1) noteCol = 5;

      final dateFormatter = DateFormat(_dateFormat, 'en_US');

      // قراءة الصفوف (تخطي الرأس)
      for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
        final row = sheet.rows[rowIndex];
        if (row.isEmpty) continue;

        try {
          final dateStr = _getCellValue(row, dateCol);
          final customerName = _getCellValue(row, customerCol);
          final directionStr = _getCellValue(row, directionCol);
          final amountStr = _getCellValue(row, amountCol);
          final note = _getCellValue(row, noteCol);

          // تخطي صفوف الإجمالي
          if (dateStr.isEmpty && customerName.isEmpty) continue;
          if (amountStr.isEmpty) continue;
          if (dateStr == 'الإجمالي' || customerName == 'الإجمالي') continue;

          // تحليل التاريخ
          DateTime? date;
          try {
            date = dateFormatter.parse(dateStr);
          } catch (_) {
            try {
              date = DateTime.tryParse(dateStr);
            } catch (_) {
              date = null;
            }
          }

          if (date == null) {
            errors.add('السطر ${rowIndex + 1}: تاريخ غير صالح "$dateStr"');
            continue;
          }

          // تحليل المبلغ
          final amountClean =
              amountStr.replaceAll(',', '').replaceAll(' ', '');
          final amount = int.tryParse(amountClean) ??
              double.tryParse(amountClean)?.toInt();
          if (amount == null || amount <= 0) {
            errors.add('السطر ${rowIndex + 1}: مبلغ غير صالح "$amountStr"');
            continue;
          }

          // تحليل الاتجاه
          bool isCredit = true; // الافتراضي: لي
          if (directionStr.isNotEmpty) {
            final dirLower = directionStr.toLowerCase();
            if (dirLower.contains('عليّا') ||
                dirLower.contains('عليا') ||
                dirLower.contains('عليه') ||
                dirLower.contains('أعطيته') ||
                dirLower.contains('debit') ||
                dirLower == 'false') {
              isCredit = false;
            }
          }

          entries.add(EntryModel(
            id: '', // سيُضاف ID جديد عند الإدخال
            amount: amount,
            isCredit: isCredit,
            date: date,
            note: note == '-' ? '' : note,
            customerName: customerName == '-' ? '' : customerName,
            syncStatus: 1,
          ));
        } catch (e) {
          errors.add('السطر ${rowIndex + 1}: خطأ في القراءة - $e');
        }
      }

      return ExcelImportResult(
        entries: entries,
        errors: errors,
        successCount: entries.length,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Excel import error: $e');
      return ExcelImportResult(
        entries: [],
        errors: ['خطأ في قراءة الملف: $e'],
        successCount: 0,
      );
    }
  }

  static String _getCellValue(List<Data?> row, int colIndex) {
    if (colIndex < 0 || colIndex >= row.length) return '';
    final cell = row[colIndex];
    if (cell == null || cell.value == null) return '';
    return cell.value.toString().trim();
  }
}

class ExcelImportResult {
  final List<EntryModel> entries;
  final List<String> errors;
  final int successCount;

  ExcelImportResult({
    required this.entries,
    required this.errors,
    required this.successCount,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => successCount > 0;
}
