import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/entry_model.dart';

class PdfService {

  /// تنظيف النص من الأحرف المخفية التي تسبب خطأ في PDF
  static String cleanText(String text) {
    return text
        .replaceAll('\u202A', '')
        .replaceAll('\u202B', '')
        .replaceAll('\u202C', '')
        .replaceAll('\u202D', '')
        .replaceAll('\u202E', '')
        .replaceAll('\u200E', '')
        .replaceAll('\u200F', '');
  }

  static Future<Uint8List> generateReport({
    required List<EntryModel> entries,
    required String reportTitle,
    String? customerName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {

    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/myfont.ttf"); 
    final fontDataBold = await rootBundle.load("assets/myfont.ttf"); 
    
    final ttf = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(fontDataBold);
    final ByteData imageBytes = await rootBundle.load('assets/accounts_logo_light.png');
    final Uint8List imageData = imageBytes.buffer.asUint8List();

    // 2. تحويل البيانات إلى صورة تفهمها مكتبة الـ PDF
    final pw.MemoryImage pdfImage = pw.MemoryImage(imageData);
    // التاريخ مع الوقت
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final amountFormatter = NumberFormat('#,##0');

    double totalCredit = 0;
    double totalDebit = 0;

    for (final e in entries) {
      if (e.isCredit) {
        totalCredit += e.amount;
      } else {
        totalDebit += e.amount;
      }
    }

    final balance = totalCredit - totalDebit;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttfBold,
        ),
        margin: const pw.EdgeInsets.all(32),

        header: (context) => _buildHeader(
          reportTitle,
          customerName,
          fromDate,
          toDate,
          dateFormatter,
          pdfImage
        ),

        footer: (context) => _buildFooter(context),

        build: (context) => [

          /// صندوق الملخص
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            margin: const pw.EdgeInsets.only(bottom: 20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
              color: PdfColors.grey100,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [

                _buildSummaryColumn(
                  'إجمالي لي',
                  amountFormatter.format(totalCredit),
                  PdfColors.green800,
                ),

                pw.Container(width: 1, height: 40, color: PdfColors.grey400),

                _buildSummaryColumn(
                  'إجمالي عليّا',
                  amountFormatter.format(totalDebit),
                  PdfColors.red800,
                ),

                pw.Container(width: 1, height: 40, color: PdfColors.grey400),

                _buildSummaryColumn(
                  'الرصيد',
                  '${balance >= 0 ? "+" : ""}${amountFormatter.format(balance)}',
                  balance >= 0 ? PdfColors.green800 : PdfColors.red800,
                ),
              ],
            ),
          ),

          /// الجدول مع تلوين الصفوف
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(25),
              1: const pw.FlexColumnWidth(2.0),
              2: const pw.FlexColumnWidth(1.8),
              3: const pw.FlexColumnWidth(1.4),
              4: const pw.FlexColumnWidth(1.8),
              5: const pw.FlexColumnWidth(2.2),
            },
            children: [
              // رأس الجدول
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                children: [
                  _buildHeaderCell('#', ttfBold),
                  _buildHeaderCell('التاريخ', ttfBold),
                  _buildHeaderCell('العميل', ttfBold),
                  _buildHeaderCell('النوع', ttfBold),
                  _buildHeaderCell('المبلغ', ttfBold),
                  _buildHeaderCell('ملاحظة', ttfBold),
                ],
              ),
              // صفوف البيانات
              ...List.generate(entries.length, (i) {
                final e = entries[i];
                final isOdd = i % 2 == 0;
                final bgColor = isOdd ? PdfColors.grey100 : PdfColors.white;
                final typeColor = e.isCredit ? PdfColors.green800 : PdfColors.red800;
                final typeText = e.isCredit ? 'لي' : 'عليّا';
                final amountText = '${e.isCredit ? '+' : '-'}${amountFormatter.format(e.amount)}';

                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bgColor),
                  children: [
                    _buildDataCell('${i + 1}', ttf, PdfColors.grey700),
                    _buildDataCell(dateFormatter.format(e.date), ttf, PdfColors.grey800),
                    _buildDataCell(e.customerName.isEmpty ? '-' : cleanText(e.customerName), ttf, PdfColors.grey800),
                    _buildDataCell(typeText, ttfBold, typeColor),
                    _buildDataCell(amountText, ttfBold, typeColor),
                    _buildDataCell(e.note.isEmpty ? '-' : cleanText(e.note), ttf, PdfColors.grey700),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          /// صندوق الإجمالي
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              border: pw.Border.all(color: PdfColors.blue800),
              borderRadius: pw.BorderRadius.circular(4),
            ),

            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

              children: [

                pw.Text(
                  'عدد العمليات: ${entries.length}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),

                pw.Text(
                  'صافي الرصيد: ${balance >= 0 ? "+" : ""}${amountFormatter.format(balance)}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: balance >= 0
                        ? PdfColors.green800
                        : PdfColors.red800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeaderCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  static pw.Widget _buildDataCell(String text, pw.Font font, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: 8,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _buildHeader(
    String title,
    String? customerName,
    DateTime? fromDate,
    DateTime? toDate,
    DateFormat dateFormatter,
    pw.ImageProvider pdfImage
  ) {

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),

      child: 
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

            children: [
              pw.Text(
                'تطبيق\n حساباتي',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Image(pdfImage,
                width: 80, // يمكنك التحكم بالعرض
                height: 80, // يمكنك التحكم بالطول
                fit: pw.BoxFit.contain, // طريقة احتواء الصورة
              
              ),

      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
              pw.Text(
                'تاريخ التقرير: ${dateFormatter.format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                'نوع التقرير: $title',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
          

          if (customerName != null)
            pw.Text(
              'العميل: ${cleanText(customerName)}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),

          // if (fromDate != null || toDate != null)
          //   pw.Text(
          //     'الفترة: ${fromDate != null ? dateFormatter.format(fromDate) : "..."} - ${toDate != null ? dateFormatter.format(toDate) : "..."}',
          //     style: const pw.TextStyle(
          //       fontSize: 12,
          //       color: PdfColors.grey700,
          //     ),
          //   ),
            ],
          ),

        //   pw.SizedBox(height: 8),


        //   pw.Divider(
        //     color: PdfColors.blue800,
        //     thickness: 2,
        //   ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),

      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

        children: [

          pw.Text(
            'تم الإنشاء بواسطة OwnAccounts',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),

          pw.Text(
            'الصفحة ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryColumn(
      String label,
      String value,
      PdfColor color,
      ) {

    return pw.Column(
      children: [

        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),

        pw.SizedBox(height: 4),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
