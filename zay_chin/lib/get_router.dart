import 'package:go_router/go_router.dart';
import 'package:zay_chin/screen/cart_screen.dart';
import 'package:zay_chin/screen/home_screen.dart';
import 'package:zay_chin/screen/login_screen.dart';
import 'package:zay_chin/screen/profile_setup_screen.dart';
import 'package:zay_chin/screen/register_screen.dart';
import 'package:zay_chin/screen/welcome_screen.dart';
import 'package:zay_chin/screen/splash_screen.dart';

GoRouter getRouter() {
  return GoRouter(
    initialLocation: "/splash",
    routes: [
      GoRoute(path: "/splash", builder: (context, state) => const SplashScreen()),
      GoRoute(path: "/", builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: "/register", builder: (context, state) => const RegisterScreen()),
      GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
      GoRoute(path: "/profile/setup", builder: (context, state) => const ProfileSetupScreen()),
      GoRoute(path: "/home", builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: "/cart/:groupId",
        builder: (context, state) => CartScreen(
          groupId: state.pathParameters['groupId']!,
        ),
      ),
    ],
  );
}
