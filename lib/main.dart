import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZeroFit',
      theme: ThemeData(
        primarySwatch: Colors.pink,
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                color: Color.fromRGBO(255, 182, 163, 1.0),
              )
          )
      ),
      home: const OnboardingScreen(),
    );
  }
}
