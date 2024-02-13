part of './app_pages.dart';

abstract class Routes {
  Routes._();

  static const LOGIN = _Paths.LOGIN;
  static const MAIN = _Paths.MAIN;
  static const JOIN = _Paths.JOIN;
  static const SETTING = _Paths.SETTING;
  // TODO: Add More Routes
}

abstract class _Paths {
  static const LOGIN = "/login";
  static const MAIN = "/main";
  static const JOIN = "/join";
  static const SETTING = "/setting";
  // TODO: Add More Paths
}
