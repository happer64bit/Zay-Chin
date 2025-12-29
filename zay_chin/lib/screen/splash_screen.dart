import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zay_chin/api/client.dart';
import 'package:zay_chin/api/services/profile_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final apiClient = ApiClient();
    apiClient.init();

    final hasToken = apiClient.hasToken();

    if (!mounted) return;

    if (!hasToken) {
      context.go('/');
      return;
    }

    try {
      final hasProfile = await _profileService.hasProfile();
      if (!mounted) return;
      if (hasProfile) {
        context.go('/home');
      } else {
        context.go('/profile/setup');
      }
    } catch (_) {
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
