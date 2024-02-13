import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String nickname = "유저";
    String profileImageUrl = "image.jpg";

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 프로필 사진
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 16),
            // 회원 닉네임
            Text(
              '닉네임: $nickname',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
