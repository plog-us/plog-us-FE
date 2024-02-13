import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plog_us/app/core/base/base_view.dart';
import 'package:plog_us/app/view/login_page/login_page.dart';
import 'package:plog_us/app/view/map_page/map_page.dart';
import 'package:plog_us/app/view/mypage_page/mypage_page.dart';
import 'package:plog_us/app/view/signup_page/signup_page.dart';

import '../../controllers/main/main_controller.dart';

class MainPage extends BaseView<MainController> {
  MainPage({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    // TODO: implement appBar
    return AppBar(
      title: const Text('Main Page'),
    );
    //throw UnimplementedError();
  }

  @override
  Widget body(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text('Signup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
              child: const Text('Map'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPageScreen()),
                );
              },
              child: const Text('MyPage'),
            ),
          ],
        ),
      ),
    );
  }
}
