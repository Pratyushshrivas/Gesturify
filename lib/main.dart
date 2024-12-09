import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hackfinity/screens/splash_screen.dart';
import 'package:hackfinity/utils/strings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Strings strings = Strings();

    return MaterialApp(
      title: strings.projectName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
