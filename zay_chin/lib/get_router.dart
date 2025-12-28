import 'package:go_router/go_router.dart';
import 'package:zay_chin/screen/login_screen.dart';
import 'package:zay_chin/screen/register_screen.dart';

import 'package:zay_chin/screen/welcome_screen.dart';

GoRouter list = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => WelcomeScreen()),
    GoRoute(path: "/register", builder: (context, state) => RegisterScreen()),
    GoRoute(path: "/login", builder: (context, state) => LoginScreen()),
  ],
);

GoRouter getRouter() {
  return list;
}
