import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reciperover/Components/TextField.dart';
import 'package:reciperover/Components/consts.dart';
import 'package:reciperover/Screens/dashboard/dashboard.dart';
import 'package:reciperover/Screens/signupscreen.dart';
import 'package:reciperover/auth_services.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  AuthService _authService = AuthService();
  CollectionReference _users = FirebaseFirestore.instance.collection('users');

  FirebaseAuth _auth = FirebaseAuth.instance;

  void handleSignIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.toString(),
          password: _passController.text.toString());

      bool userExist =
          await _authService.CheckIfUserExist(_emailController.text);
      User? user = userCredential.user;
      if (user != null) {
        if (userExist) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyHomePage()));
        } else {
       
        }
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("User does not exist"),
            ),
          );
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Login")),
        backgroundColor: Color(0xFF6F35A5),
      ),
      resizeToAvoidBottomInset:
          true, // Adjusts screen to avoid keyboard overlap
      body: SingleChildScrollView(
        // Allows content to scroll
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logom.png",
              width: 200,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Login",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F35A5)),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: TextFieldContainer(
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      hintText: "Enter Email",
                      prefixIcon: Icon(Icons.person),
                      prefixIconColor: DarkPurple,
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6F35A5))),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6F35A5)))),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: TextFieldContainer(
                child: TextField(
                  controller: _passController,
                  decoration: InputDecoration(
                      hintText: "Enter Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(
                        Icons.visibility,
                        color: DarkPurple,
                      ),
                      prefixIconColor: DarkPurple,
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6F35A5))),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6F35A5)))),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: 300,
              height: 40,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Color(0xFF6F35A5), width: 2.0),
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF6F35A5)),
                  elevation: MaterialStateProperty.all<double>(0.0),
                ),
                onPressed: handleSignIn,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()));
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: DarkPurple),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
