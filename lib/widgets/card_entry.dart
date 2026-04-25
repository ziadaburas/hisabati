import 'package:flutter/material.dart';

import '../models/entry_model.dart';
import '../theme/app_theme.dart';

class CustomEntryTile extends StatelessWidget {
  final String title;
  final Color mainColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData icon;
  final Widget? amountWidget;
  final Widget? bottomRow;
  final Widget? deleteWidget;
  final VoidCallback? onTap;
  final double elevation;

  const CustomEntryTile({
    super.key,
    required this.title,
    required this.mainColor,
    required this.icon,
    this.backgroundColor,
    this.borderColor,
    this.amountWidget,
    this.bottomRow,
    this.deleteWidget,
    this.onTap,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              right: BorderSide(
                color: mainColor,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              // أيقونة السهم
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: mainColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // المحتوى الأوسط
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // العنوان (لي أو عليا)
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'myfont',
                            color: mainColor,
                          ),
                        ),

                        // القيمة (ويدجت اختياري)
                        if (amountWidget != null) amountWidget!,
                      ],
                    ),

                    // الصف السفلي (التاريخ والملاحظة - ويدجت اختياري)
                    if (bottomRow != null) ...[
                      const SizedBox(height: 4),
                      bottomRow!,
                    ],
                  ],
                ),
              ),

              // زر الحذف (ويدجت اختياري)
              if (deleteWidget != null) ...[
                const SizedBox(width: 4),
                deleteWidget!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CardEntryTile extends StatelessWidget {
  final EntryModel entry;
  final VoidCallback? onTap; // دالة النقر
  final VoidCallback? onDelete; // دالة الحذف

  const CardEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = entry.isCredit ? AppColors.success : AppColors.error;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : Colors.grey.shade500;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isDark ? 0 : 1,
      color: isDark ? AppColors.darkCard : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? const BorderSide(color: AppColors.darkDivider)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              right: BorderSide(
                color: mainColor,
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
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  entry.isCredit
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: mainColor,
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
                            color: mainColor,
                          ),
                        ),
                        Text(
                          entry.isCredit ? 'لي' : 'عليا',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: mainColor,
                          ),
                        ),
                        BackColorText(
                          text: '${entry.isCredit ? '+' : '-'}${entry.amount}',
                          color: mainColor,
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: subtitleColor),
                        const SizedBox(width: 4),
                        Text(
                          entry.date.toString().split(" ").first,
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                        if (entry.note.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.note_rounded,
                              size: 12, color: subtitleColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.note,
                              style: TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
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
                onPressed: onDelete,
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
}

class BackColorText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const BackColorText(
      {super.key, required this.text, required this.color, this.fontSize = 13});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
