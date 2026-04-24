import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/entries_controller.dart';
import '../services/sync_service.dart';
import '../services/database_service.dart';
import '../services/google_drive_service.dart';
import '../services/connectivity_service.dart';

class SyncController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final GoogleDriveService driveService = GoogleDriveService();
  final ConnectivityService _connectivity = ConnectivityService();

  late final SyncService _syncService;

  final Rx<SyncState> syncState = SyncState.synced.obs;
  final RxString syncMessage = ''.obs;
  final RxInt pendingChanges = 0.obs;
  final RxBool isSyncing = false.obs;

  // متغير لتتبع userId الحالي
  String? _currentUserId;

  @override
  void onInit() {
    super.onInit();
    _syncService = SyncService(_db, driveService, _connectivity);
    _connectivity.init();

    // الاستماع لتغييرات الاتصال
    _connectivity.addListener(() {
      if (_connectivity.isOnline) {
        // عند الاتصال بالإنترنت - تحقق فوراً من القيود المعلقة وزامنها
        if (_currentUserId != null) {
          _autoSyncWithUserId(_currentUserId!);
        }
      } else {
        syncState.value = SyncState.offline;
        // عرض عدد القيود غير المزامنة عند قطع الاتصال
        if (_currentUserId != null) {
          _updatePendingCount(_currentUserId!);
        }
      }
    });
  }

  void setAccessToken(String? token) {
    if (token != null) {
      driveService.setAccessToken(token);
    }
  }

  /// تعيين userId الحالي وبدء المراقبة
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    // تحقق من القيود المعلقة عند بدء الجلسة
    checkAndAutoSync(userId);
  }

  Future<void> _updatePendingCount(String userId) async {
    final count = await _db.countPendingChanges(userId);
    pendingChanges.value = count;
    if (count > 0 && !_connectivity.isOnline) {
      syncState.value = SyncState.pending;
      syncMessage.value = '$count قيد غير مزامن';
    }
  }

  Future<void> checkPendingChanges(String userId) async {
    final count = await _db.countPendingChanges(userId);
    pendingChanges.value = count;
   // if (count > 0) {
      // إذا كنا متصلين - زامن تلقائياً في الخلفية
      if (_connectivity.isOnline) {
        _autoSyncWithUserId(userId);
      } else {
        syncState.value = SyncState.pending;
        syncMessage.value = '$count قيد غير مزامن';
      }
   // }
  }

  /// تحقق عند بدء التطبيق وزامن تلقائياً إذا كان هناك قيود معلقة
  Future<void> checkAndAutoSync(String userId) async {
    _currentUserId = userId;
    final count = await _db.countPendingChanges(userId);
    pendingChanges.value = count;

    if (count > 0) {
      if (_connectivity.isOnline) {
        // زامن تلقائياً في الخلفية
        syncState.value = SyncState.syncing;
        syncMessage.value = 'جاري المزامنة التلقائية...';
        _autoSyncWithUserId(userId);
      } else {
        syncState.value = SyncState.pending;
        syncMessage.value = '$count قيد غير مزامن';
      }
    } else if (!_connectivity.isOnline) {
      syncState.value = SyncState.offline;
      syncMessage.value = 'غير متصل بالإنترنت';
    }
  }

  /// مزامنة تلقائية في الخلفية
  void _autoSyncWithUserId(String userId) {
    // نفذ في الخلفية بدون انتظار
    Future.microtask(() => syncNow(userId));
  }

  Future<void> syncNow(String userId) async {
    if (isSyncing.value) return;
    _currentUserId = userId;
    isSyncing.value = true;
    syncState.value = SyncState.syncing;
    syncMessage.value = 'جاري المزامنة...';

    try {
      final result = await _syncService.syncNow(userId);
      syncState.value = result.state;
      syncMessage.value = result.message;

      if (result.state == SyncState.synced) {
        pendingChanges.value = 0;
        // إعادة تحميل القيود بعد المزامنة
        try {
          final entriesController = Get.find<EntriesController>();
          entriesController.loadEntries(userId);
        } catch (_) {}

        // إخفاء شريط المزامنة بعد 3 ثواني
        Future.delayed(const Duration(seconds: 3), () {
          if (syncState.value == SyncState.synced) {
            syncMessage.value = '';
          }
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Sync controller error: $e');
      syncState.value = SyncState.error;
      syncMessage.value = 'خطأ في المزامنة، بياناتك المحلية سليمة';
    }

    isSyncing.value = false;
  }

  Future<void> deleteAllCloudData(String userId) async {
    try {
      syncState.value = SyncState.syncing;
      syncMessage.value = 'جاري حذف البيانات السحابية...';
      await driveService.deleteAllData();
      syncState.value = SyncState.synced;
      syncMessage.value = 'تم حذف البيانات السحابية';
      Future.delayed(const Duration(seconds: 3), () {
        if (syncState.value == SyncState.synced) {
          syncMessage.value = '';
        }
      });
    } catch (e) {
      syncState.value = SyncState.error;
      syncMessage.value = 'فشل حذف البيانات السحابية';
      rethrow;
    }
  }

  void reset() {
    _currentUserId = null;
    syncState.value = SyncState.synced;
    syncMessage.value = '';
    pendingChanges.value = 0;
    isSyncing.value = false;
  }

  @override
  void onClose() {
    _connectivity.dispose();
    super.onClose();
  }
}
