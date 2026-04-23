import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '/controllers/entries_controller.dart';
import '../models/entry_model.dart';
import 'database_service.dart';
import 'google_drive_service.dart';
import 'connectivity_service.dart';

enum SyncState { synced, syncing, pending, error, offline }

class SyncService {
  final DatabaseService _db;
  final GoogleDriveService _drive;
  final ConnectivityService _connectivity;

  SyncService(this._db, this._drive, this._connectivity);
  
  Future<SyncResult> syncNow(String userId) async {
    if (!_connectivity.isOnline) {
      return SyncResult(
        state: SyncState.offline,
        message: 'لا يوجد اتصال بالإنترنت',
      );
    }

    try {
      // 1. جلب التغييرات المحلية المعلقة والمحذوفة
      final pendingEntries = await _db.getPendingEntries(userId);
      final deletedEntries = await _db.getDeletedEntries(userId);
      
      // جلب كل القيود لمعرفة ما إذا كان التطبيق "جديداً" (فارغاً)
      final allLocalEntries = await _db.getEntries(userId);
      final isAppCompletelyNew = allLocalEntries.isEmpty;

      // 2. تنزيل بيانات السحابة
      final cloudEntriesResult = await _drive.downloadEntries();

      if (cloudEntriesResult == null) {
        // خطأ في التنزيل
        if (pendingEntries.isNotEmpty && !isAppCompletelyNew) {
          // إذا كان لدينا بيانات محلية معلقة، نحاول رفعها كنسخة احتياطية
          final success = await _drive.uploadEntries(allLocalEntries);
          if (success) {
            for (final entry in allLocalEntries) {
              await _db.markAsSynced(userId, entry.id);
            }
            return SyncResult(state: SyncState.synced, message: 'تم رفع النسخة المحلية');
          }
        }
        return SyncResult(state: SyncState.error, message: 'تعذر الاتصال بالسحابة');
      }

      // --- الحالة الأولى: التطبيق جديد تماماً (قاعدة البيانات فارغة) ---
      if (isAppCompletelyNew) {
        if (cloudEntriesResult.isNotEmpty) {
          // يوجد نسخة في السحابة -> استرجاع فوري
          await _db.replaceAllEntries(userId, cloudEntriesResult);
          try {
          if (Get.isRegistered<EntriesController>()) {
            // نستخدم await لضمان تحميل البيانات قبل إخفاء شريط المزامنة
            await Get.find<EntriesController>().loadEntries(userId);
          }
        } catch (e) {
          if (kDebugMode) debugPrint('Error reloading entries after sync: $e');
        }
          return SyncResult(
            state: SyncState.synced, 
            message: 'تم استرجاع بياناتك من السحابة بنجاح',
            entriesCount: cloudEntriesResult.length,
          );
        } else {
          // لا يوجد بيانات في السحابة والتطبيق جديد
          return SyncResult(state: SyncState.synced, message: 'تم تجهيز السحابة لحسابك');
        }
      }

      // --- الحالة الثانية: لا توجد أي تغييرات محلية (لا يوجد إضافة/تعديل/حذف) ---
      if (pendingEntries.isEmpty && deletedEntries.isEmpty) {
        // بما أنه لا يوجد تغييرات محلية، نحدث القاعدة المحلية بما في السحابة فقط (لتوفير الإنترنت)
        if (cloudEntriesResult.isNotEmpty) {
           await _db.replaceAllEntries(userId, cloudEntriesResult);
        }
        return SyncResult(
          state: SyncState.synced, 
          message: 'بياناتك محدثة',
          entriesCount: cloudEntriesResult.length,
        );
      }

      // --- الحالة الثالثة: يوجد تغييرات محلية (نحتاج لدمج ورفع) ---
      
      // 3. دمج البيانات
      final mergedEntries = _mergeEntries(
        cloudEntriesResult,
        pendingEntries,
        deletedEntries,
      );

      // 4. رفع البيانات المدمجة للسحابة
      final uploadSuccess = await _drive.uploadEntries(mergedEntries);
      if (!uploadSuccess) {
        if (kDebugMode) debugPrint('Sync: Upload failed');
        return SyncResult(
          state: SyncState.error,
          message: 'فشل رفع البيانات، بياناتك المحلية محفوظة',
        );
      }

      // 5. تحديث القاعدة المحلية بعد نجاح الرفع
      await _db.replaceAllEntries(userId, mergedEntries);

      // 6. تنظيف القيود المحذوفة محلياً
      for (final entry in deletedEntries) {
        await _db.hardDeleteEntry(userId, entry.id);
      }

      return SyncResult(
        state: SyncState.synced,
        message: 'تمت المزامنة بنجاح',
        entriesCount: mergedEntries.length,
      );

    } catch (e) {
      if (kDebugMode) debugPrint('Sync error: $e');
      return SyncResult(
        state: SyncState.error,
        message: 'خطأ في المزامنة، بياناتك المحلية سليمة',
      );
    }
  }

  List<EntryModel> _mergeEntries(
    List<EntryModel> cloud,
    List<EntryModel> pending,
    List<EntryModel> deleted,
  ) {
    final deletedIds = deleted.map((e) => e.id).toSet();
    final Map<String, EntryModel> merged = {};

    for (final entry in cloud) {
      if (!deletedIds.contains(entry.id)) {
        merged[entry.id] = entry;
      }
    }

    for (final entry in pending) {
      if (!deletedIds.contains(entry.id)) {
        merged[entry.id] = entry.copyWith(syncStatus: 1); // ✅ تم التعديل هنا لتصبح 1 (مزامنة) لأننا سنرفعها
      }
    }

    return merged.values.toList();
  }
}

class SyncResult {
  final SyncState state;
  final String message;
  final int entriesCount;

  SyncResult({
    required this.state,
    required this.message,
    this.entriesCount = 0,
  });
}