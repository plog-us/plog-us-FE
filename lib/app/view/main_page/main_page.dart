import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plog_us/app/core/base/base_view.dart';
import 'package:plog_us/app/view/classify_page/classify_page.dart';
import 'package:plog_us/app/view/leaderboard_page/leaderboard_page.dart';
import 'package:plog_us/app/view/login_page/login_page.dart';
import 'package:plog_us/app/view/map_page/map_page.dart';
import 'package:plog_us/app/view/mypage_page/mypage_page.dart';
import 'package:plog_us/app/view/quiz_page/quiz_page.dart';
import 'package:plog_us/app/view/signup_page/signup_page.dart';
import 'package:plog_us/app/view/theme/app_colors.dart';

import 'package:plog_us/app/controllers/login/login_controller.dart';
import '../../controllers/main/main_controller.dart';

class MainPage extends BaseView<MainController> {
  MainPage({super.key});
  String username_example = "user";
  final LoginController _loginController = Get.put(LoginController());

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: const Text('Plogus'),
    );
  }

  @override
  Widget body(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 150,
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_loginController.username} 님 환영합니다!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyPageScreen()),
                          );
                        },
                        child: const Text('마이페이지 바로가기',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  padding: const EdgeInsets.all(16.0),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ClassifyPage()),
                        );
                      },
                      icon: const Icon(
                        Icons.camera,
                        color: AppColors.black,
                      ),
                      label: const Text(
                        'Classify',
                        style: TextStyle(
                          fontSize: 23,
                          color: AppColors.black,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.greenOrigin),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MapScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.map,
                        color: AppColors.black,
                      ),
                      label: const Text(
                        'Map',
                        style: TextStyle(
                          fontSize: 23,
                          color: AppColors.black,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.greenOrigin),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QuizScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.quiz,
                        color: AppColors.black,
                      ),
                      label: const Text(
                        'Quiz',
                        style: TextStyle(
                          fontSize: 23,
                          color: AppColors.black,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.greenOrigin),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.golf_course_rounded,
                        color: AppColors.black,
                      ),
                      label: const Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.black,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.greenOrigin),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
