import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zay_chin/get_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: getRouter(),
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
        // textTheme: GoogleFonts.poppinsTextTheme()
      ),
    );
  }
}