import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/entries_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        body: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.primaryMedium, AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x330F3D2E),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الإعدادات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'myfont',
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'تخصيص التطبيق وإدارة البيانات',
                              style: TextStyle(
                                color: Color(0xFFB2D8C8),
                                fontSize: 12,
                                fontFamily: 'myfont',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== بيانات المستخدم =====
                    _buildSectionHeader('بيانات المستخدم', Icons.person_rounded, isDark),
                    const SizedBox(height: 12),
                    Obx(() {
                      final user = authController.user.value;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark ? null : AppShadows.cardShadow,
                          border: isDark
                              ? Border.all(color: AppColors.darkDivider)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryLight.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primaryMedium.withOpacity(0.15),
                                backgroundImage: user?.photoUrl.isNotEmpty == true
                                    ? NetworkImage(user!.photoUrl)
                                    : null,
                                child: user?.photoUrl.isEmpty != false
                                    ? Text(
                                        user?.displayName.isNotEmpty == true
                                            ? user!.displayName[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          fontFamily: 'myfont',
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.displayName ?? 'المستخدم',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'myfont',
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'myfont',
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // ===== المظهر =====
                    _buildSectionHeader('المظهر', Icons.palette_rounded, isDark),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark ? null : AppShadows.cardShadow,
                        border: isDark
                            ? Border.all(color: AppColors.darkDivider)
                            : null,
                      ),
                      child: Obx(() => Column(
                            children: [
                              _buildThemeOption(
                                context,
                                themeController,
                                0,
                                'تبع النظام',
                                Icons.brightness_auto_rounded,
                                'يتبع إعدادات الجهاز تلقائياً',
                                isDark,
                              ),
                              Divider(
                                  color: isDark ? AppColors.darkDivider : AppColors.lightGray,
                                  height: 1),
                              _buildThemeOption(
                                context,
                                themeController,
                                1,
                                'فاتح',
                                Icons.light_mode_rounded,
                                'مظهر فاتح دائماً',
                                isDark,
                              ),
                              Divider(
                                  color: isDark ? AppColors.darkDivider : AppColors.lightGray,
                                  height: 1),
                              _buildThemeOption(
                                context,
                                themeController,
                                2,
                                'داكن',
                                Icons.dark_mode_rounded,
                                'مظهر داكن دائماً',
                                isDark,
                              ),
                            ],
                          )),
                    ),

                    const SizedBox(height: 24),

                    // ===== البيانات =====
                    _buildSectionHeader('إدارة البيانات', Icons.storage_rounded, isDark),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark ? null : AppShadows.cardShadow,
                        border: isDark
                            ? Border.all(color: AppColors.darkDivider)
                            : null,
                      ),
                      child: Column(
                        children: [
                          // حذف البيانات المحلية
                          _buildActionTile(
                            icon: Icons.delete_sweep_rounded,
                            title: 'حذف البيانات المحلية',
                            subtitle: 'حذف جميع القيود المخزنة على الجهاز',
                            color: Colors.orange,
                            isDark: isDark,
                            onTap: () => _confirmDeleteLocalData(context, isDark),
                          ),
                          Divider(
                              color: isDark ? AppColors.darkDivider : AppColors.lightGray,
                              height: 1,
                              indent: 16,
                              endIndent: 16),
                          // حذف البيانات السحابية
                          _buildActionTile(
                            icon: Icons.cloud_off_rounded,
                            title: 'حذف البيانات السحابية',
                            subtitle: 'حذف جميع البيانات من Google Drive',
                            color: AppColors.error,
                            isDark: isDark,
                            onTap: () => _confirmDeleteCloudData(context, isDark),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== تسجيل الخروج =====
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmLogout(context, isDark),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'myfont',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          shadowColor: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App version
                    Center(
                      child: Text(
                        'OwnAccounts - الإصدار 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                          fontFamily: 'myfont',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primaryMedium,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: AppColors.primaryMedium, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontFamily: 'myfont',
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeController themeController,
    int value,
    String title,
    IconData icon,
    String subtitle,
    bool isDark,
  ) {
    final isSelected = themeController.themeValue.value == value;

    return InkWell(
      onTap: () => themeController.setTheme(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryMedium.withOpacity(0.12)
                    : (isDark ? AppColors.darkSurface : AppColors.background),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryMedium : AppColors.mediumGray,
                size: 20,
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: isSelected
                          ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      fontFamily: 'myfont',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                      fontFamily: 'myfont',
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primaryMedium,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : AppColors.lightGray,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontFamily: 'myfont',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                      fontFamily: 'myfont',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                size: 22),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteLocalData(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_sweep_rounded,
                    color: Colors.orange, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'حذف البيانات المحلية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'myfont',
                  color: isDark ? AppColors.darkTextPrimary : null,
                ),
              ),
            ],
          ),
          content: Text(
            'سيتم حذف جميع القيود المخزنة على هذا الجهاز. هذا الإجراء لا يمكن التراجع عنه.\n\nملاحظة: البيانات السحابية لن تتأثر.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'myfont',
              color: isDark ? AppColors.darkTextSecondary : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                    fontFamily: 'myfont'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteLocalData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('حذف', style: TextStyle(fontFamily: 'myfont')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCloudData(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_off_rounded,
                    color: AppColors.error, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'حذف البيانات السحابية',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'myfont',
                    color: isDark ? AppColors.darkTextPrimary : null,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'سيتم حذف جميع البيانات المخزنة في Google Drive بشكل نهائي. هذا الإجراء لا يمكن التراجع عنه.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'myfont',
              color: isDark ? AppColors.darkTextSecondary : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                    fontFamily: 'myfont'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCloudData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('حذف نهائي', style: TextStyle(fontFamily: 'myfont')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  fontFamily: 'myfont',
                  color: isDark ? AppColors.darkTextPrimary : null,
                ),
              ),
            ],
          ),
          content: Text(
            'هل تريد تسجيل الخروج من حسابك؟',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'myfont',
              color: isDark ? AppColors.darkTextSecondary : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                    fontFamily: 'myfont'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.find<AuthController>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('خروج', style: TextStyle(fontFamily: 'myfont')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteLocalData() async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.user.value?.uid;
      if (userId == null) return;

      final db = DatabaseService();
      await db.clearUserData(userId);

      final entriesController = Get.find<EntriesController>();
      await entriesController.loadEntries(userId);

      Get.snackbar(
        'تم الحذف',
        'تم حذف جميع البيانات المحلية بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف البيانات: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  Future<void> _deleteCloudData() async {
    try {
      final syncController = Get.find<SyncController>();
      final success = await syncController.driveService.deleteAllData();

      if (success) {
        Get.snackbar(
          'تم الحذف',
          'تم حذف جميع البيانات السحابية بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل حذف البيانات السحابية',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف البيانات: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }
}
