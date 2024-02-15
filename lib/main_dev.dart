import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/main.dart';
import 'package:plog_us/flavors/build_config.dart';
import 'package:plog_us/flavors/env_config.dart';
import 'package:plog_us/flavors/environment.dart';

void main() async {
  EnvConfig devConfig = EnvConfig(
    appName: "Plog-Us",
    baseUrl: "",
    shouldCollectCrashLog: true,
  );

  BuildConfig.instantiate(
    envType: Environment.DEVELOPMENT,
    envConfig: devConfig,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}
