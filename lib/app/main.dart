import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:plog_us/app/routes/app_pages.dart';
import 'package:plog_us/flavors/build_config.dart';
import 'package:plog_us/flavors/env_config.dart';
import 'package:plog_us/app/bindings/initial_binding.dart';
import 'view/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final EnvConfig _envConfig = BuildConfig.instance.config;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      builder: (buildContext, widget) => GetMaterialApp(
        title: _envConfig.appName,
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.pages,
        initialBinding: InitialBinding(),
        theme: appThemeData,
        defaultTransition: Transition.fade,
      ),
    );
  }
}
