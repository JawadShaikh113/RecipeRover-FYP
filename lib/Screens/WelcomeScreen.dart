import 'package:flutter/material.dart';
import 'package:reciperover/Components/consts.dart';
import 'package:reciperover/Screens/loginscreen.dart';
import 'package:reciperover/Screens/signupscreen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            // Center the whole content
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Vertically center the column
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Horizontally center the column
                  children: [
                    Text(
                      "Recipe Rover",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontFamily: "DenkOne"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      'assets/logom.png',
                      height: 250,
                    ),
                    SizedBox(
                      height: 55,
                    ),
                    Container(
                      width: 300,
                      height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: DarkPurple, width: 2.0),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          elevation: MaterialStateProperty.all<double>(0.0),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Login In',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: DarkPurple),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 300,
                      height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: DarkPurple, width: 2.0),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(DarkPurple),
                          elevation: MaterialStateProperty.all<double>(0.0),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => SignUpScreen())));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
