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
    String apiUrl = 'http://35.212.208.171:8080/editprofile/$userUuid';
    if (_imageFile == null) {
      showBlackPopup("갤러리에서 이미지를 선택하세요");
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
    String apiUrl = 'http://35.212.208.171:8080/deleteprofile/$userUUid';

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
                                      String newUsername =
                                          usernameController.text;
                                      updateUsername(newUsername,
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
                          onPressed: () {
                            showChangePasswordPopup(context);
                          },
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
                            showBlackPopup("로그아웃되었습니다.");
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
    String apiUrl = 'http://35.212.208.171:8080/mypage/$userUuid';

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
    showBlackPopup("프로필 이미지가 삭제되었습니다.");
    setState(() {
      _imageFile = null;
    });
    setState(() {});
  }

  Future<void> updateUsername(String newUsername, String userId) async {
    String apiUrl = 'http://35.212.208.171:8080/modify/username/$userId';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, String> body = {
      'username': newUsername,
    };

    String jsonBody = json.encode(body);

    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        showBlackPopup("이름 변경에 성공했습니다.");
        setState(() {});
      } else {
        print('Failed to update username. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    Get.back();
  }

  Future<void> updatePassword(String newPassword, String userId) async {
    LoginController loginController = Get.find<LoginController>();
    String apiUrl = 'http://35.212.208.171:8080/modify/password/$userId';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, String> body = {
      'password': newPassword,
    };

    String jsonBody = json.encode(body);

    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        showBlackPopup("비밀번호 변경에 성공했습니다. 다시 로그인해주세요.");
        setState(() {});
      } else {
        print('Failed to update username. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void showBlackPopup(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.white),
        ),
      ),
    );
  }

  void showChangePasswordPopup(BuildContext context) {
    String newPassword = "";
    LoginController loginController = Get.find<LoginController>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("비밀번호 변경"),
          content: TextField(
            onChanged: (value) {
              newPassword = value;
            },
            decoration: const InputDecoration(hintText: "새 비밀번호 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                updatePassword(newPassword, loginController.userId.value);
                Navigator.of(context).pop();
                loginController.setUserId("");
                Get.toNamed('/login');
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
