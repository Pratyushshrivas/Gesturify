import 'package:flutter/material.dart';

import 'package:hackfinity/screens/home_second.dart';
import 'package:hackfinity/utils/assets.dart';
import 'package:hackfinity/utils/strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Assets assets = Assets();
    Strings strings = Strings();

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            assets.logo,
            width: width * 0.7,
            height: width * 0.7,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            strings.projectName,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(
              left: 40,
              right: 40,
              bottom: 40,
            ),
            width: width,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    // builder: (context) => const HomeScreen(),
                    builder: (context) => const HomeScreenSecond(),
                    // builder: (context) => const HomeScreenPratyush(),
                    // builder: (context) => const HomeScreenGemini(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                strings.start,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
