import 'package:get/get.dart';

class LoginController extends GetxController {
  var userId = ''.obs;
  var username = ''.obs;

  void setUserId(String id) {
    userId.value = id;
  }

  void setUserName(String name) {
    username.value = name;
  }
}
