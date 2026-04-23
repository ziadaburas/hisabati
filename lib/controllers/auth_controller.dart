import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'entries_controller.dart';
import 'sync_controller.dart';
import '../views/login/login_view.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isSigningIn = false.obs;
  final RxString error = ''.obs;
  final RxBool isInitialCheckDone = false.obs;
  bool get isLoggedIn => user.value != null;
  
  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      final token = await _authService.getAccessToken();
      user.value = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        photoUrl: firebaseUser.photoURL ?? '',
        accessToken: token,
      );
      //_initAfterLogin();
    }
    isInitialCheckDone.value = true;
  }

  Future<bool> signInWithGoogle() async {
    isSigningIn.value = true;
    error.value = '';
    try {
      final userModel = await _authService.signInWithGoogle();
      if (userModel != null) {
        user.value = userModel;
        isSigningIn.value = false;
        initAfterLogin();
        return true;
      }
      isSigningIn.value = false;
      return false;
    } catch (e) {
      error.value = e.toString();
      isSigningIn.value = false;
      return false;
    }
  }

  void initAfterLogin() {
    if (user.value == null) return;

    // Initialize sync controller with access token
    final syncController = Get.find<SyncController>();
    syncController.setAccessToken(user.value!.accessToken);
    
    // Load entries
    final entriesController = Get.find<EntriesController>();
    entriesController.loadEntries(user.value!.uid);

    // تعيين المستخدم الحالي في SyncController لبدء المراقبة التلقائية
    syncController.setCurrentUser(user.value!.uid);
  }

  Future<void> refreshToken() async {
    final token = await _authService.getAccessToken();
    if (token != null && user.value != null) {
      user.value = UserModel(
        uid: user.value!.uid,
        email: user.value!.email,
        displayName: user.value!.displayName,
        photoUrl: user.value!.photoUrl,
        accessToken: token,
      );
      Get.find<SyncController>().setAccessToken(token);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    user.value = null;
    Get.find<EntriesController>().clearEntries();
    Get.find<SyncController>().reset();
    // العودة لصفحة تسجيل الدخول وإزالة كل الصفحات السابقة
    Get.offAll(() => const LoginView());
  }
}
