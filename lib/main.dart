import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reciperover/Screens/WelcomeScreen.dart';
import 'package:reciperover/firebase_options.dart';
import 'package:reciperover/data_uploader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DataUploader().uploadData();
    Timer(Duration(seconds: 3), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => WelcomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                // Colors.orange.shade100, // Darker shade of purple
                // Colors.purple.shade100, // Mid shade of purple
                // Colors.brown.shade200, // Lighter shade of purple
                Color.fromARGB(255, 170, 130, 207),
                Color.fromARGB(255, 122, 170, 218),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logom.png',
                  width: 300,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Recipe Rover",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      // fontWeight: FontWeight.bold,
                      fontFamily: "DenkOne"),
                ),
                SizedBox(
                  height: 10,
                ),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
