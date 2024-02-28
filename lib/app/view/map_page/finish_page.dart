import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plog_us/app/view/theme/app_colors.dart';
import 'package:http/http.dart' as http;

class FinishScreen extends StatefulWidget {
  final String locationName;
  final Stopwatch stopwatch;
  final Timer timer;
  final String finalUuid;

  const FinishScreen({
    super.key,
    required this.locationName,
    required this.stopwatch,
    required this.timer,
    required this.finalUuid,
  });

  @override
  State<FinishScreen> createState() => _FinishScreenState();
}

class _FinishScreenState extends State<FinishScreen> {
  String plogwastebin = "";
  @override
  void initState() {
    super.initState();
    _getWastebin();
  }

  Future<void> _getWastebin() async {
    String apiUrl = 'http://35.212.208.171:8080/wastebin/${widget.finalUuid}';

    try {
      print(apiUrl);
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var responseData = utf8.decode(response.bodyBytes); // UTF-8 디코딩
        var jsonData = json.decode(responseData);
        print(jsonData);

        List<dynamic> wastebins = json.decode(responseData);
        setState(() {
          String wastebin =
              wastebins.isNotEmpty ? wastebins[0]['binAddress'] : '';
          plogwastebin = wastebin;
          print('Wastebin: $wastebin');
        });
      } else {
        print('배출함 찾기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('시작 중 오류 발생: $e');
    }
  }

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
                '플로깅 위치: ${widget.locationName}',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '배출함 위치: $plogwastebin',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              '플로깅 시간: ${widget.stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(widget.stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
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
