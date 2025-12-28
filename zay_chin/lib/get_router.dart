import 'package:go_router/go_router.dart';

import 'package:zay_chin/screen/welcome_screen.dart';

GoRouter list = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => WelcomeScreen()),
  ],
);

GoRouter getRouter() {
  return list;
}
