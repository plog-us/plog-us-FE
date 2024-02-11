import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:plog_us/app/core/page_state.dart';
import 'package:plog_us/flavors/build_config.dart';

abstract class BaseController extends GetxController {
  final Logger logger = BuildConfig.instance.config.logger;

  final _pageStateController = PageState.DEFAULT.obs;

  PageState get pageState => _pageStateController.value;

  updatePageState(PageState state) => _pageStateController(state);
  resetPageState() => _pageStateController(PageState.DEFAULT);

  final _messageController = ''.obs;
  String get message => _messageController.value;
  showMessage(String msg) => _messageController(msg);

  final _errorMessageController = ''.obs;
  String get errorMessage => _errorMessageController.value;
  showErrorMessage(String msg) {
    _errorMessageController(msg);
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1);
  }

  @override
  void onClose() {
    _pageStateController.close();
    super.onClose();
  }
}
