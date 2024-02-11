import 'package:flutter/material.dart';
import 'app/main.dart';
import 'package:plog_us/flavors/build_config.dart';
import 'package:plog_us/flavors/env_config.dart';
import 'package:plog_us/flavors/environment.dart';

void main() {
  EnvConfig devConfig = EnvConfig(
    appName: "Plog-Us",
    baseUrl: "",
    shouldCollectCrashLog: true,
  );

  BuildConfig.instantiate(
    envType: Environment.DEVELOPMENT,
    envConfig: devConfig,
  );
  runApp(const App());
}
