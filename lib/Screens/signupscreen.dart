import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reciperover/Components/TextField.dart';
import 'package:reciperover/Components/consts.dart';
import 'package:reciperover/auth_services.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePass = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController interestController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  void _handleSignUp() async {
    try {
      final User? user = await _authService.signUp(
        emailController.text,
        passwordController.text,
        nameController.text,
        interestController.text,
      );

      if (user != null) {
        final userData = {
          'uid': user.uid,
          'name': nameController.text,
          'email': emailController.text,
          'interest': interestController.text,
          'phoneNumber': "",
          'profile': "",
          'onlineStatus': "",
        };

        await users.doc(user.uid).set(userData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sign up successful!"),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sign up failed!"),
            ),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Sign Up")),
        backgroundColor: DarkPurple,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Image.asset(
                "assets/logom.png",
                width: 190,
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFieldContainer(
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Enter Name",
                          prefixIcon: Icon(Icons.person),
                          prefixIconColor: DarkPurple,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: DarkPurple)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: DarkPurple)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter Name";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFieldContainer(
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          prefixIcon: Icon(Icons.account_circle),
                          prefixIconColor: DarkPurple,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: DarkPurple)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: DarkPurple)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFieldContainer(
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePass,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: DarkPurple,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePass = !_obscurePass;
                              });
                            },
                          ),
                          prefixIconColor: DarkPurple,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: DarkPurple)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: DarkPurple)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter Password";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters long";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFieldContainer(
                      child: TextFormField(
                        controller: interestController,
                        decoration: InputDecoration(
                          hintText: "Interests (Veg/ Non Veg)",
                          prefixIcon: Icon(Icons.restaurant_menu),
                          prefixIconColor: DarkPurple,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: DarkPurple)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: DarkPurple)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your interest";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 30),
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
                          if (_formKey.currentState!.validate()) {
                            print('Sign Up button pressed!');
                            _handleSignUp();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Sign Up',
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
            ],
          ),
        ),
      ),
    );
  }
}
