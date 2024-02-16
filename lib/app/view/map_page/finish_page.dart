import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plog_us/app/view/theme/app_colors.dart';

class FinishScreen extends StatelessWidget {
  final String locationName;
  final Stopwatch stopwatch;
  final Timer timer;

  const FinishScreen({
    super.key,
    required this.locationName,
    required this.stopwatch,
    required this.timer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/images/check.png', // 로고 이미지 경로
                width: 100, // 이미지 너비
                height: 100, // 이미지 높이
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              '플로깅이 종료되었습니다! ',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '플로깅 위치: $locationName',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              '플로깅 시간: ${stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/main');
              },
              child: const Text(
                '메인으로 돌아가기',
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.blueOrigin,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
