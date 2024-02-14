import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plog_us/app/controllers/login/login_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plog_us/app/view/theme/app_colors.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(String userUuid) async {
    String apiUrl = 'http://35.212.137.41:8080/editprofile/$userUuid';
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          content: Text(
            "이미지를 선택하세요",
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
      return;
    }

    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(apiUrl));
      request.files.add(
        http.MultipartFile(
          'userProfile', // Adjusted key to 'userProfile'
          _imageFile!.readAsBytes().asStream(),
          _imageFile!.lengthSync(),
          filename: _imageFile!.path.split('/').last,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('이미지 업로드 성공!');
        _profilechange();
      } else {
        print('이미지 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
    }
  }

  Future<void> _deleteImage(String userUUid) async {
    String apiUrl = 'http://35.212.137.41:8080/deleteprofile/$userUUid';

    try {
      var response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        _profiledelete();
      } else {
        print('삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('삭제 중 오류 발생: $e');
    }
  }

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
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : userData['userProfile'] != null
                                ? NetworkImage(userData['userProfile'])
                                : const AssetImage(
                                        'assets/images/blank_user.png')
                                    as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            _uploadImage(logoutController.userId.value);
                          },
                          child: const Text(
                            '프로필 사진 저장',
                            style: TextStyle(
                              color: AppColors.blueOrigin,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteImage(logoutController.userId.value);
                          },
                          child: const Text(
                            '프로필 사진 삭제',
                            style: TextStyle(
                              color: AppColors.blueOrigin,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${userData['username']}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            TextEditingController usernameController =
                                TextEditingController(
                                    text: userData['username']);
                            Get.dialog(
                              AlertDialog(
                                title: const Text('이름 변경'),
                                content: TextFormField(
                                  controller: usernameController,
                                  decoration: const InputDecoration(
                                    hintText: '새로운 사용자 이름을 입력하세요',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // 변경 버튼 눌렀을 때 API 요청 보내기
                                      String newUsername =
                                          usernameController.text;
                                      // 여기서 API 요청 보내고 응답 처리
                                      // 이후에 Get.back()을 호출하여 팝업 닫기
                                      // 예시: _updateUsername(newUsername);
                                      _updateUsername(newUsername,
                                          logoutController.userId.value);
                                    },
                                    child: const Text('변경'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back(); // 취소 버튼 눌렀을 때 팝업 닫기
                                    },
                                    child: const Text('취소'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            '비밀번호 변경',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
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
                      ],
                    ),
                    const SizedBox(width: 16.0),
                  ],
                ),
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

  void _profilechange() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.greenOrigin,
        content: Text(
          "프로필 이미지 업로드 성공!",
          style: TextStyle(color: AppColors.black),
        ),
      ),
    );
    setState(() {});
  }

  void _profiledelete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        content: Text(
          "프로필 이미지가 삭제되었습니다.",
          style: TextStyle(color: AppColors.white),
        ),
      ),
    );
    setState(() {
      _imageFile = null;
    });
    setState(() {});
  }

  void _updateUsername(String newUsername, String userId) {
    print("변경");
    Get.back();
  }
}
