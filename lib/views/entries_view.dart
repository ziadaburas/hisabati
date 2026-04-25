import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/entries_controller.dart';
import '../models/entry_model.dart';
import '../theme/app_theme.dart';
import '../widgets/card_entry.dart';
import 'add_entry_view.dart';

// ignore: must_be_immutable
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
                entriesController.entries[index],
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
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اضغط على (+) لإضافة قيد جديد',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSubtitle,
            ),
          ),
        ],
      ),
    );
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
