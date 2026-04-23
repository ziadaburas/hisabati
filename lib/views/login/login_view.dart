import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/sync_controller.dart';
import '../../controllers/auth_controller.dart';
import '../home/home_view.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF0D47A1),
              Color(0xFF0A2E6B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity( 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity( 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'OwnAccounts',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'إدارة حساباتك بسهولة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity( 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      Icons.receipt_long_rounded,
                      'تتبع جميع قيودك المالية',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.people_rounded,
                      'إدارة حسابات العملاء',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.cloud_sync_rounded,
                      'مزامنة على Google Drive',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.picture_as_pdf_rounded,
                      'تقارير PDF احترافية',
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isSigningIn.value
                          ? null
                          : () => _handleSignIn(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1565C0),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity( 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: controller.isSigningIn.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1565C0),
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  'تسجيل الدخول بحساب Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                'بياناتك محفوظة في Google Drive الخاص بك',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity( 0.6),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity( 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignIn() async {
    final success = await controller.signInWithGoogle();
    
    if (success) {
      // ✅ تمت إضافة كود الانتقال هنا
      // نستخدم Get.offAll لمسح شاشة تسجيل الدخول من الذاكرة حتى لا يعود إليها المستخدم عند الضغط على زر الرجوع
      Get.offAll(() => const HomeView()); 
      var authController = Get.find<AuthController>();
      var syncController = Get.find<SyncController>();
      final userId = 
                               authController.user.value?.uid;
                              if (userId != null) {
                                authController.refreshToken().then((_) {
                                  syncController.syncNow(userId);
                                });
                              }
    } else if (controller.error.value.isNotEmpty) {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الدخول: ${controller.error.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
