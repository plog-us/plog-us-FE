// ignore_for_file: use_build_context_synchronously

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:plog_us/app/view/theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _allFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkAllFieldsFilled);
    _emailController.addListener(_checkAllFieldsFilled);
    _passwordController.addListener(_checkAllFieldsFilled);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkAllFieldsFilled() {
    setState(() {
      _allFieldsFilled = _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
      print('모든 필드가${_allFieldsFilled.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    double textSize = 24.0;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/plant.png', // 로고 이미지 경로
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 150.0,
                height: 50,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 40.0,
                    color: Colors.black,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText('PlogUs',
                          speed: const Duration(milliseconds: 250)),
                      TypewriterAnimatedText('Welcome!'),
                    ],
                    repeatForever: false,
                    totalRepeatCount: 1,
                    onTap: () {
                      print("Tap Event");
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
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
              const SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
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
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
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
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  _allFieldsFilled ? _signUp(context) : _notfilled();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _allFieldsFilled
                        ? const Color.fromARGB(255, 0, 0, 0)
                        : AppColors.gray300,
                  ),
                  child: Text(
                    '가입하기',
                    style: TextStyle(
                        color: _allFieldsFilled
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp(BuildContext context) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    String url = 'http://35.212.208.171:8080/join';

    Map<String, dynamic> body = {
      'username': name,
      'password': password,
      'email': email,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"content-type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('가입 성공! 아이디: $email, 비밀번호: $password');

        var responseData = json.decode(response.body);
        String userId = responseData['email'];
        Navigator.of(context).pushNamed('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 161, 229, 161),
            content: Text(
              "회원가입에 성공했습니다.",
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      } else {
        print('POST request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              "회원가입에 실패했습니다",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "오류가 발생했습니다. 다시 시도해주세요.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _notfilled() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.black,
        content: Text(
          "모든 텍스트를 입력해주세요",
          style: TextStyle(color: AppColors.white),
        ),
      ),
    );
  }
}
