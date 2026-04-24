import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../views/reports/reports_page.dart';
import '../views/import_export/import_export_page.dart';
import '../views/settings/settings_view.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Drawer(
        width: 285,
        backgroundColor: AppColors.drawerBackground,
        child: Column(
          children: [
            _buildDrawerHeader(authController),
            Divider(color: AppColors.drawerDivider, height: 1, thickness: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  _buildMenuItem(
                    icon: Icons.home_rounded,
                    label: 'الرئيسية',
                    index: 0,
                    onTap: () {
                      Navigator.of(context).pop();
                      onItemSelected(0);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'القيود',
                    index: 1,
                    onTap: () {
                      Navigator.of(context).pop();
                      onItemSelected(1);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.people_rounded,
                    label: 'العملاء',
                    index: 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      onItemSelected(3);
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(color: AppColors.drawerDivider, height: 1),
                  const SizedBox(height: 8),
                  // التقارير - تفتح واجهة جديدة
                  _buildMenuItem(
                    icon: Icons.assessment_rounded,
                    label: 'التقارير',
                    index: -1,
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.to(() => const ReportsPage());
                    },
                  ),
                  // التصدير والاستيراد - تفتح واجهة جديدة
                  _buildMenuItem(
                    icon: Icons.import_export_rounded,
                    label: 'التصدير والاستيراد',
                    index: -2,
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.to(() => const ImportExportPage());
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(color: AppColors.drawerDivider, height: 1),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.cloud_sync_rounded,
                    label: 'المزامنة والنسخ الاحتياطي',
                    index: 5,
                    onTap: () {
                      Navigator.of(context).pop();
                      onItemSelected(5);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    label: 'الإعدادات',
                    index: -3,
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.to(() => const SettingsView());
                    },
                  ),
                ],
              ),
            ),
            _buildDrawerFooter(context, authController),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(AuthController authController) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 20,
        bottom: 20,
        right: 20,
        left: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF166A4A), Color(0xFF0F3D2E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/accounts_logo.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OwnAccounts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'myfont',
                    ),
                  ),
                  Text(
                    'إدارة حساباتك بسهولة',
                    style: TextStyle(
                      color: Color(0xFF9DBFB4),
                      fontSize: 11,
                      fontFamily: 'myfont',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final user = authController.user.value;
            return Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryLight.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    backgroundImage: user?.photoUrl.isNotEmpty == true
                        ? NetworkImage(user!.photoUrl)
                        : null,
                    child: user?.photoUrl.isEmpty != false
                        ? Text(
                            user?.displayName.isNotEmpty == true
                                ? user!.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'myfont',
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'المستخدم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'myfont',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 11,
                          fontFamily: 'myfont',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryLight.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryLight.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isActive
                        ? AppColors.primaryLight
                        : AppColors.bottomNavInactive,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? AppColors.primaryLight : Colors.white.withOpacity(0.85),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'myfont',
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context, AuthController authController) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).padding.bottom + 16,
        top: 12,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        border: Border(
          top: BorderSide(color: AppColors.drawerDivider, width: 1),
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                color: Color(0xFF6B9E8E),
                fontSize: 11,
                fontFamily: 'myfont',
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showLogoutConfirm(context, authController),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'myfont',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  fontFamily: 'myfont',
                ),
              ),
            ],
          ),
          content: const Text(
            'هل تريد تسجيل الخروج من حسابك؟',
            style: TextStyle(fontSize: 14, fontFamily: 'myfont'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.mediumGray, fontFamily: 'myfont'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('خروج', style: TextStyle(fontFamily: 'myfont')),
            ),
          ],
        ),
      ),
    );
  }
}
