import 'package:get/get.dart';
import 'package:plog_us/app/controllers/login/login_controller.dart';
import 'package:plog_us/app/controllers/main/main_controller.dart';

class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() {
      return MainController();
    });
    Get.lazyPut<LoginController>(() {
      return LoginController();
    });
  }
}
