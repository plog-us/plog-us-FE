import 'dart:async';

import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Finish Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('플로깅 위치: $locationName'),
            Text(
                '플로깅 시간: ${stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}'),
          ],
        ),
      ),
    );
  }
}
