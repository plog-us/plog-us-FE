import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plog_us/app/core/base/base_view.dart';

import '../../controllers/main/main_controller.dart';

class MainPage extends BaseView<MainController> {
  MainPage({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    // TODO: implement appBar
    return AppBar(
      title: const Text('Main Page'),
    );
    //throw UnimplementedError();
  }

  @override
  Widget body(BuildContext context) {
    return Container(
      child: const Center(
        child: Text('Main Page'),
      ),
    );
  }
}
