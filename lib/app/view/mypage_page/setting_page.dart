import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plog_us/app/controllers/login/login_controller.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.find<LoginController>();
    return Scaffold(
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
                  Row(
                    children: [
                      const SizedBox(width: 22),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: userData['userProfile'] != null
                            ? NetworkImage(userData['userProfile'])
                            : const AssetImage('assets/images/blank_user.png')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '${userData['username']}',
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '프로필 사진 변경하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '비밀번호 변경하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        Text(
                          '닉네임 변경하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed('/login');
                    },
                    child: const Text(
                      '회원탈퇴',
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
