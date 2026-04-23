import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/entries_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../models/entry_model.dart';
import '../../widgets/sync_status_bar.dart';
import '../add_entry/add_entry_view.dart';
import '../customer_entries/customer_entries_view.dart';
import '../reports/reports_view.dart';
import '../import_export/import_export_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final authController = Get.find<AuthController>();
    final entriesController = Get.find<EntriesController>();

    return WillPopScope(
      onWillPop: () async {
        // رسالة تأكيد عند الضغط على زر الرجوع
        final shouldExit = await _showExitConfirmDialog(context);
        if (shouldExit) {
          // إغلاق التطبيق فعلياً
          SystemNavigator.pop();
        }
        return false; // نمنع الرجوع التلقائي دائماً
      },
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              // Custom AppBar with user info + sync status
              _buildAppBar(context, authController, entriesController),
              // Sync status bar
              const SyncStatusBar(),
              // Tab content
              Expanded(
                child: Obx(() {
                  switch (homeController.currentTabIndex.value) {
                    case 0:
                      return _buildEntriesTab(entriesController, authController);
                    case 1:
                      return _buildCustomersTab(entriesController);
                    case 2:
                      return const ReportsView();
                    case 3:
                      return const ImportExportView();
                    default:
                      return _buildEntriesTab(entriesController, authController);
                  }
                }),
              ),
            ],
          ),
          bottomNavigationBar: Obx(() => Directionality(
            textDirection: ui.TextDirection.ltr,
            child: NavigationBar(
                  selectedIndex: homeController.currentTabIndex.value,
                  onDestinationSelected: homeController.changeTab,
                  backgroundColor: Colors.white,
                  elevation: 8,
                  indicatorColor: const Color(0xFF1565C0).withOpacity(0.12),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long_rounded,
                          color: Color(0xFF1565C0)),
                      label: 'القيود',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outlined),
                      selectedIcon:
                          Icon(Icons.people_rounded, color: Color(0xFF1565C0)),
                      label: 'العملاء',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.assessment_outlined),
                      selectedIcon: Icon(Icons.assessment_rounded,
                          color: Color(0xFF1565C0)),
                      label: 'التقارير',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.import_export_outlined),
                      selectedIcon: Icon(Icons.import_export_rounded,
                          color: Color(0xFF1565C0)),
                      label: 'تصدير/استيراد',
                    ),
                  ],
                ),
          )),
          floatingActionButton: Obx(() {
            if (homeController.currentTabIndex.value == 2 ||
                homeController.currentTabIndex.value == 3) {
              return const SizedBox.shrink();
            }
            return FloatingActionButton.extended(
              onPressed: () => Get.to(() => const AddEntryView()),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'إضافة قيد',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.exit_to_app_rounded, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text(
                'الخروج من البرنامج',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'هل تريد الخروج من البرنامج؟',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Color(0xFF1565C0)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('خروج'),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }
  // ✅ تم إزالة Obx من هنا والاعتماد على الـ Obx الخارجي
  Widget _buildEntriesTab(
      EntriesController controller, AuthController authController) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا توجد قيود بعد',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على "إضافة قيد" للبدء',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final userId = authController.user.value?.uid;
        if (userId != null) {
          await controller.loadEntries(userId);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: controller.entries.length,
        itemBuilder: (context, index) {
          return _buildEntryCard(
              context, controller.entries[index], controller, authController);
        },
      ),
    );
  }

  // ✅ تم إزالة Obx من هنا أيضاً
  Widget _buildCustomersTab(EntriesController controller) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final customers = controller.customerSummaries;
    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا يوجد عملاء بعد',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف قيد مع اسم عميل للبدء',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index].value;
        return _buildCustomerCard(customer);
      },
    );
  }
  Widget _buildAppBar(BuildContext context, AuthController authController,
      EntriesController entriesController) {
    return Container(
      color: const Color(0xFF1565C0),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row: user info + logout
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  // User photo
                  Obx(() {
                    final user = authController.user.value;
                    return GestureDetector(
                      onTap: () => _showUserMenu(context, authController),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withOpacity(0.2),
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
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  // User name and email
                  Expanded(
                    child: Obx(() {
                      final user = authController.user.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'المستخدم',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  // Sync button
                  Obx(() {
                    final syncController = Get.find<SyncController>();
                    return IconButton(
                      onPressed: syncController.isSyncing.value
                          ? null
                          : () {
                              final userId =
                                  authController.user.value?.uid;
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Icon(Icons.cloud_sync_rounded,
                              color: Colors.white),
                    );
                  }),
                  // Logout button
                  IconButton(
                    onPressed: () =>
                        _showLogoutConfirm(context, authController),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    tooltip: 'تسجيل الخروج',
                  ),
                ],
              ),
            ),
            // Balance summary
            Obx(() => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBalanceItem(
                          'لي',
                          entriesController.totalCredit,
                          const Color(0xFF4CAF50),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildBalanceItem(
                          'عليا',
                          entriesController.totalDebit,
                          const Color(0xFFEF5350),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildBalanceItem(
                          'الرصيد',
                          entriesController.totalBalance,
                          Colors.white,
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

  Widget _buildBalanceItem(String label, double amount, Color color) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatter.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEntriesTab1(
      EntriesController controller, AuthController authController) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'لا توجد قيود بعد',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اضغط على "إضافة قيد" للبدء',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          final userId = authController.user.value?.uid;
          if (userId != null) {
            await controller.loadEntries(userId);
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: controller.entries.length,
          itemBuilder: (context, index) {
            return _buildEntryCard(
                context, controller.entries[index], controller, authController);
          },
        ),
      );
    });
  }

  Widget _buildEntryCard(BuildContext context, EntryModel entry,
      EntriesController controller, AuthController authController) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'en_US');
    final amountFormatter = NumberFormat('#,##0', 'en_US');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => AddEntryView(editEntry: entry)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              right: BorderSide(
                color: entry.isCredit
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: entry.isCredit
                      ? const Color(0xFF4CAF50).withOpacity( 0.1)
                      : const Color(0xFFEF5350).withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  entry.isCredit
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: entry.isCredit
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.customerName.isNotEmpty
                                ? entry.customerName
                                : 'بدون اسم',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: entry.customerName.isNotEmpty
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${entry.isCredit ? '+' : '-'}${amountFormatter.format(entry.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: entry.isCredit
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF5350),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatter.format(entry.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (entry.note.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.note_rounded,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.note,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
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
              // Delete button
              IconButton(
                onPressed: () =>
                    _confirmDelete(context, entry, controller, authController),
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade300, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, EntryModel entry,
      EntriesController controller, AuthController authController) {
    Get.defaultDialog(
      title: 'حذف القيد',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText:
          'هل أنت متأكد من حذف هذا القيد؟\n\n${entry.customerName.isNotEmpty ? entry.customerName : "بدون اسم"} - ${entry.amount}',
      textConfirm: 'حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: const Color(0xFF1565C0),
      onConfirm: () {
        final userId = authController.user.value?.uid;
        if (userId != null) {
          controller.deleteEntry(userId, entry.id);
          Get.back();
          Get.snackbar(
            'تم الحذف',
            'تم حذف القيد بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      },
    );
  }

  Widget _buildCustomersTab1(EntriesController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final customers = controller.customerSummaries;
      if (customers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_rounded, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'لا يوجد عملاء بعد',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أضف قيد مع اسم عميل للبدء',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index].value;
          return _buildCustomerCard(customer);
        },
      );
    });
  }

  Widget _buildCustomerCard(CustomerSummary customer) {
    final amountFormatter = NumberFormat('#,##0', 'en_US');
    final isPositive = customer.balance >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            Get.to(() => CustomerEntriesView(customerName: customer.name)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildMiniChip(
                          'لي: ${amountFormatter.format(customer.totalCredit)}',
                          const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 8),
                        _buildMiniChip(
                          'عليا: ${amountFormatter.format(customer.totalDebit)}',
                          const Color(0xFFEF5350),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountFormatter.format(customer.balance.abs()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isPositive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPositive ? 'لي' : 'عليا',
                    style: TextStyle(
                      fontSize: 12,
                      color: isPositive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${customer.entryCount} قيد',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_left_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context, AuthController authController) {
    final user = authController.user.value;
    if (user == null) return;

    Get.bottomSheet(
      Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    const Color(0xFF1565C0).withOpacity(0.1),
                backgroundImage: user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : null,
                child: user.photoUrl.isEmpty
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showLogoutConfirm(context, authController);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('تسجيل الخروج'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(
      BuildContext context, AuthController authController) {
    Get.defaultDialog(
      title: 'تسجيل الخروج',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'هل تريد تسجيل الخروج من التطبيق؟',
      textConfirm: 'خروج',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: const Color(0xFF1565C0),
      onConfirm: () {
        Get.back();
        authController.signOut();
      },
    );
  }
}
