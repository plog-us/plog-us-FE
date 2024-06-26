import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:plog_us/app/core/base/base_controller.dart';
import 'package:plog_us/flavors/build_config.dart';

import '../../view/widgets/loading.dart';
import '../../view/theme/app_colors.dart';
import '../page_state.dart';

abstract class BaseView<Controller extends BaseController>
    extends GetView<Controller> {
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  final Logger logger = BuildConfig.instance.config.logger;

  BaseView({super.key});

  Widget body(BuildContext context);

  PreferredSizeWidget? appBar(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        children: [
          annotatedRegion(context),
          Obx(() => controller.pageState == PageState.LOADING
              ? _showLoading()
              : Container()),
          Obx(() => controller.errorMessage.isNotEmpty
              ? showErrorSnackBar(controller.errorMessage)
              : Container()),
          Container(),
        ],
      ),
    );
  }

  //statusBar부분
  Widget annotatedRegion(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
            statusBarColor: statusBarColor(),
            statusBarIconBrightness: Brightness.dark),
        child: Material(
          color: Colors.transparent,
          child: pageScaffold(context),
        ));
  }

  bool? resizeToAvoidBottomInset;
  //scaffold부분
  Widget pageScaffold(BuildContext context) {
    return Scaffold(
      //sets ios status bar color
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: pageBackgroundColor(),
      key: globalKey,
      appBar: appBar(context),
      floatingActionButton: floatingActionButton(),
      body: pageContent(context),
      bottomNavigationBar: bottomNavigationBar(),
      bottomSheet: bottomSheet(),
      drawer: drawer(),
    );
  }

  Widget pageContent(BuildContext context) {
    return SafeArea(
      child: body(context),
    );
  }

  //에러 스낵바 표시
  Widget showErrorSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    });

    return Container();
  }

  //토스트 메세지 띄우기
  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1);
  }

  //배경색 지정
  Color pageBackgroundColor() {
    return AppColors.pageBackground;
  }

  //statusBar 색 지정
  Color statusBarColor() {
    return AppColors.pageBackground;
  }

  //플로팅 액션바
  Widget? floatingActionButton() {
    return null;
  }

  //바텀네비
  Widget? bottomNavigationBar() {
    return null;
  }

  //바텀시트
  Widget? bottomSheet() {
    return null;
  }

  // 메뉴 드로워
  Widget? drawer() {
    return null;
  }

  // 로딩
  Widget _showLoading() {
    return const Loading();
  }
}
