import 'package:bengkel_terdekat/screen/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bengkel Terdekat',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}
