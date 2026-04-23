import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/entries_controller.dart';
import '../controllers/sync_controller.dart';
import '../controllers/home_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Services are initialized inside controllers
    Get.put(SyncController(), permanent: true);
    Get.put(EntriesController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(HomeController(), permanent: true);
  }
}
