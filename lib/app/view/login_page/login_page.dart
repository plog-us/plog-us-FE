import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plog_us/app/controllers/login/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _loginController = Get.put(LoginController());
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                _Login();
              },
              child: const Text('로그인'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleGoogleSignIn,
              child: const Text('Google로 로그인'),
            ),
          ],
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

      var responseData = json.decode(response.body);
      String userId = responseData['userUuid'].toString();
      _loginController.setUserId(userId);
    } else {
      print('POST request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('가입 실패: ${response.reasonPhrase}');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('가입 실패'),
            content: Text('서버 에러: ${response.reasonPhrase}'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}
