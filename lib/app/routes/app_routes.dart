part of './app_pages.dart';

abstract class Routes {
  Routes._();

  static const LOGIN = _Paths.LOGIN;
  static const MAIN = _Paths.MAIN;
  // TODO: Add More Routes
}

abstract class _Paths {
  static const LOGIN = "/login";
  static const MAIN = "/main";
  // TODO: Add More Paths
}
