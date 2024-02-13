import 'package:get/get.dart';

class LoginController extends GetxController {
  var userId = ''.obs;

  void setUserId(String id) {
    userId.value = id;
  }
}
