import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'store.dart';

void main() async{
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (c) => Store1(),
      child :MaterialApp(
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
     )
    );
  }
}
