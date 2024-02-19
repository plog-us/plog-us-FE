import 'package:flutter/material.dart';
import 'package:plog_us/app/core/base/base_view.dart';
import 'package:plog_us/app/view/login_page/login_page.dart';
import 'package:plog_us/app/view/map_page/map_page.dart';
import 'package:plog_us/app/view/mypage_page/mypage_page.dart';
import 'package:plog_us/app/view/signup_page/signup_page.dart';
import 'package:plog_us/app/view/theme/app_colors.dart';

import '../../controllers/main/main_controller.dart';

class MainPage extends BaseView<MainController> {
  MainPage({super.key});

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
                height: 150, // 유저 정보를 보여주는 컨테이너의 높이
                color: Colors.grey[200], // 컨테이너의 배경색
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'User 님 환영합니다!', // 여기에 유저 이름을 표시
                        style: TextStyle(
                          fontSize: 24, // 유저 이름의 폰트 크기
                          fontWeight: FontWeight.bold, // 유저 이름의 폰트 두께
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '마이페이지 바로가기', // 여기에 유저 이름을 표시
                        style: TextStyle(
                          fontSize: 18, // 유저 이름의 폰트 크기
                          // 유저 이름의 폰트 두께
                        ),
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
                              builder: (context) => const MyPageScreen()),
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
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.quiz,
                        color: AppColors.black,
                      ),
                      label: const Text(
                        'Login',
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
                              builder: (context) => const SignUpScreen()),
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
