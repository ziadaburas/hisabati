import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sync_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/sync_service.dart';

class SyncStatusBar extends GetView<SyncController> {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.syncState.value;
      final message = controller.syncMessage.value;
      final pending = controller.pendingChanges.value;

      // إخفاء الشريط عند المزامنة الكاملة وعدم وجود رسالة
      if (state == SyncState.synced && message.isEmpty) {
        return const SizedBox.shrink();
      }

      Color bgColor;
      IconData icon;
      bool showSyncButton = false;

      switch (state) {
        case SyncState.synced:
          bgColor = const Color(0xFF4CAF50);
          icon = Icons.cloud_done_rounded;
          break;
        case SyncState.syncing:
          bgColor = const Color(0xFF1565C0);
          icon = Icons.sync_rounded;
          break;
        case SyncState.pending:
          bgColor = const Color(0xFFFFA726);
          icon = Icons.cloud_upload_rounded;
          showSyncButton = !controller.isSyncing.value;
          break;
        case SyncState.error:
          bgColor = const Color(0xFFEF5350);
          icon = Icons.cloud_off_rounded;
          showSyncButton = !controller.isSyncing.value;
          break;
        case SyncState.offline:
          bgColor = const Color(0xFF78909C);
          icon = Icons.wifi_off_rounded;
          break;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: bgColor),
        child: Row(
          children: [
            if (state == SyncState.syncing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.isNotEmpty ? message : _defaultMessage(state, pending),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showSyncButton)
              GestureDetector(
                onTap: () {
                  final userId =
                      Get.find<AuthController>().user.value?.uid;
                  if (userId != null) {
                    final authController = Get.find<AuthController>();
                    authController.refreshToken().then((_) {
                      controller.syncNow(userId);
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'مزامنة الآن',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  String _defaultMessage(SyncState state, int pending) {
    switch (state) {
      case SyncState.synced:
        return 'تمت المزامنة';
      case SyncState.syncing:
        return 'جاري المزامنة...';
      case SyncState.pending:
        return pending > 0
            ? '$pending قيد غير مزامن - اتصل بالإنترنت للمزامنة'
            : 'في انتظار المزامنة';
      case SyncState.error:
        return 'فشلت المزامنة - اضغط للمحاولة مجدداً';
      case SyncState.offline:
        return 'غير متصل - البيانات محفوظة محلياً${pending > 0 ? " ($pending قيد غير مزامن)" : ""}';
    }
  }
}
