import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plog_us/app/controllers/login/login_controller.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.find<LoginController>();
    final LoginController logoutController = Get.put(LoginController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.toNamed('/setting'); // 이동할 스크린 경로 지정
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: _fetchUserData(loginController.userId.value),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              var userData = snapshot.data;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: userData['userProfile'] != null
                        ? NetworkImage(userData['userProfile'])
                        : const AssetImage('assets/images/blank_user.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${userData['username']}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    margin: const EdgeInsets.all(16), // 여백 지정
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // 회색 배경
                      borderRadius: BorderRadius.circular(10), // 둥근 모서리
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Plogging',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '${userData['totalPloggingScore']}',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 80,
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Quiz',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '${userData['totalQuizScore']}',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      logoutController.setUserId("");
                      Get.toNamed('/login');
                    },
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future _fetchUserData(String userUuid) async {
    String apiUrl = 'http://35.212.137.41:8080/mypage/$userUuid';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }
}
