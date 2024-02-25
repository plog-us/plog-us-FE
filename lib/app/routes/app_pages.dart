import 'package:get/get.dart';
import 'package:plog_us/app/view/login_page/login_page.dart';
import 'package:plog_us/app/view/main_page/main_page.dart';
import 'package:plog_us/app/view/map_page/map_page.dart';
import 'package:plog_us/app/view/mypage_page/setting_page.dart';
import 'package:plog_us/app/view/signup_page/signup_page.dart';
import '../bindings/main_binding.dart';
part './app_routes.dart';

class AppPages {
  AppPages._();

  // LOGIN 페이지 추가되면 바꾸기
  static const INITIAL = Routes.LOGIN;

  static final pages = [
    GetPage(
      name: _Paths.MAIN,
      page: () => MainPage(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginScreen(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.JOIN,
      page: () => const SignUpScreen(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
    ),
    // TODO: Add More Pages
  ];
}
