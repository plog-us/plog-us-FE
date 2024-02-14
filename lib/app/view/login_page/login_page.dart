import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plog_us/app/controllers/login/login_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plog_us/app/view/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _loginController = Get.put(LoginController());
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _allFieldsFilled = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();

    emailController.addListener(_checkAllFieldsFilled);
    passwordController.addListener(_checkAllFieldsFilled);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _checkAllFieldsFilled() {
    setState(() {
      _allFieldsFilled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/images/plant.png', // 로고 이미지 경로
                    width: 150, // 이미지 너비
                    height: 150, // 이미지 높이
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                GestureDetector(
                  onTap: () {
                    _allFieldsFilled ? _Login() : _notfilled();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: _handleGoogleSignIn, // _login 함수를 실행하도록 설정
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/ic_google.svg'),
                        const SizedBox(width: 16),
                        const Text(
                          "Google로 로그인하기",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/join');
                  },
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        print(
            'Google 로그인 성공: ${account.displayName}, ${account.email}, ${account.photoUrl}');
      }
    } catch (error) {
      print('Google 로그인 실패: $error');
    }
  }

  Future<void> _Login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    String url = 'http://35.212.137.41:8080/login';

    Map<String, dynamic> body = {
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"content-type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('로그인 성공! 아이디: $email, 비밀번호: $password');

      if (response.body.isEmpty) {
        _loginfailed();
        _clearTextFields();
        return;
      }

      var responseData = json.decode(response.body);

      String userId = responseData['userUuid'].toString();
      _loginController.setUserId(userId);
      Get.toNamed('/main');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.greenOrigin,
          content: Text(
            "로그인에 성공했습니다.",
            style: TextStyle(color: AppColors.black),
          ),
        ),
      );
    } else {
      print('POST request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      _loginfailed();
    }
  }

  void _notfilled() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.greenOrigin,
        content: Text(
          "모든 텍스트를 입력해주세요",
          style: TextStyle(color: AppColors.black),
        ),
      ),
    );
  }

  void _loginfailed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        content: Text(
          "로그인에 실패했습니다.",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }

  void _clearTextFields() {
    emailController.text = "";
    passwordController.text = "";
  }
}
