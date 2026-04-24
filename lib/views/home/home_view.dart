import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/entries_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/sync_status_bar.dart';
import '../add_entry/add_entry_view.dart';
import '../entries/entries_view.dart';
import '../customers/customers_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final authController = Get.find<AuthController>();
    final entriesController = Get.find<EntriesController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmDialog(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
        return false;
      },
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Obx(() => Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          drawer: AppDrawer(
            currentIndex: homeController.currentTabIndex.value,
            onItemSelected: homeController.changeTab,
          ),
          body: Column(
            children: [
              _buildAppBar(context, homeController, authController, entriesController),
              const SyncStatusBar(),
              Expanded(
                child: _buildTabContent(homeController.currentTabIndex.value),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context, homeController),
          floatingActionButton: _buildFAB(homeController),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        )),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
      case 1:
        return  EntriesView();
      case 3:
        return  CustomersView();
      default:
        return  EntriesView();
    }
  }

  Widget _buildAppBar(
    BuildContext context,
    HomeController homeController,
    AuthController authController,
    EntriesController entriesController,
  ) {
    return Container(
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => IconButton(
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      tooltip: 'القائمة',
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                     // color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:  Obx(() {
                    final user = authController.user.value;
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
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
                                  fontSize: 14,
                                  fontFamily: 'myfont',
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
               
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      final user = authController.user.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً، ${user?.displayName ?? 'المستخدم'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'myfont',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user?.email != null)
                            Text(
                              user!.email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11,
                                fontFamily: 'myfont',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      );
                    }),
                  ),
                  Obx(() {
                    final syncController = Get.find<SyncController>();
                    return IconButton(
                      onPressed: syncController.isSyncing.value
                          ? null
                          : () {
                              final userId = authController.user.value?.uid;
                              if (userId != null) {
                                authController.refreshToken().then((_) {
                                  syncController.syncNow(userId);
                                });
                              }
                            },
                      icon: syncController.isSyncing.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 25),
                      tooltip: 'مزامنة',
                    );
                  }),
                  ],
              ),
            ),
            Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBalanceItem(
                        'لي (دائن)',
                        entriesController.totalCredit,
                        AppColors.primaryLight,
                        Icons.arrow_upward_rounded,
                      ),
                    ),
                    Container(width: 1, height: 42, color: Colors.white.withOpacity(0.2)),
                    Expanded(
                      child: _buildBalanceItem(
                        'علي (مدين)',
                        entriesController.totalDebit,
                        const Color(0xFFFF8A80),
                        Icons.arrow_downward_rounded,
                      ),
                    ),
                    Container(width: 1, height: 42, color: Colors.white.withOpacity(0.2)),
                    Expanded(
                      child: _buildBalanceItem(
                        'الرصيد',
                        entriesController.totalBalance,
                        Colors.white,
                        Icons.account_balance_wallet_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, Color color, IconData icon) {
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 14),
        const SizedBox(height: 4),
        Text(
          formatter.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'myfont',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontFamily: 'myfont',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, HomeController homeController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // فقط القيود والعملاء
    final tabs = [
      {'icon': Icons.receipt_long_rounded, 'label': 'القيود', 'index': 1},
      {'icon': Icons.people_rounded, 'label': 'العملاء', 'index': 3},
    ];

    return Obx(() {
      return Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : AppColors.primaryDark,
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.primaryDark).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // القيود (يسار)
                Expanded(
                  child: _buildNavItem(
                    tabs[0]['icon'] as IconData,
                    tabs[0]['label'] as String,
                    homeController.currentTabIndex.value == 1 ||
                        homeController.currentTabIndex.value == 0,
                    () => homeController.changeTab(1),
                  ),
                ),
                // مساحة FAB
                const SizedBox(width: 70),
                // العملاء (يمين)
                Expanded(
                  child: _buildNavItem(
                    tabs[1]['icon'] as IconData,
                    tabs[1]['label'] as String,
                    homeController.currentTabIndex.value == 3,
                    () => homeController.changeTab(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryLight : AppColors.bottomNavInactive,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primaryLight : AppColors.bottomNavInactive,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'myfont',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(HomeController homeController) {
    return Container(
      width: 58,
      height: 58,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Get.to(() =>  AddEntryView()),
          child: const Center(
            child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
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
                  color: AppColors.primaryDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.exit_to_app_rounded, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'الخروج من التطبيق',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  fontFamily: 'myfont',
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'هل تريد الخروج من التطبيق؟',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'myfont',
              color: isDark ? AppColors.darkTextSecondary : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.mediumGray, fontFamily: 'myfont')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
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
    return result ?? false;
  }
}
