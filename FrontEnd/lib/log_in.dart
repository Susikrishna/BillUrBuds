import 'package:bill_ur_buds/main_menu.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";

import 'urls.dart';
import 'sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var usernameError = false;
  var passwordError = false;
  var invalidPassword = false;
  var invalidUsername = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text("LOG IN", style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text("Please, Log in to continue", style: TextStyle(color: Colors.black, fontSize: 18)),
                const SizedBox(height: 30),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    hintText: "Username",
                    errorText: invalidUsername ? "username doesn't exist!!" : usernameError ? "Cannot be empty" : null,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 3.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.password_outlined,
                      color: Colors.black,
                    ),
                    errorText: invalidPassword ? "Password is wrong" : passwordError ? "Cannot be empty" : null,
                    hintText: "Password",
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 3.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (usernameController.text.toString() == "" || passwordController.text.toString() == "") {
                      if (usernameController.text.toString() == "") {
                        usernameError = true;
                      } else {
                        usernameError = false;
                      }
                      if (passwordController.text.toString() == "") {
                        passwordError = true;
                      } else {
                        passwordError = false;
                      }
                      setState(() {});
                    } else {
                      var input = ({
                        "username": usernameController.text,
                        "password": passwordController.text,
                      });
                      var response = await http.post(Uri.parse(loginUrl),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(input));
                      var jsonResponse = jsonDecode(response.body);

                      if (jsonResponse["message"] == "success") {
                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        sharedPreferences.setString("username", usernameController.text);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MainMenu()));
                      } else if (jsonResponse["message"] == "username") {
                        usernameController.clear();
                        passwordController.clear();
                        invalidUsername = true;
                        invalidPassword = false;
                        setState(() {});
                      } else if (jsonResponse["message"] == "password") {
                        passwordController.clear();
                        invalidUsername = false;
                        invalidPassword = true;
                        setState(() {});
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadiusDirectional.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10.0,
                          ),
                        ]
                    ),
                    width: 80,
                    height: 50,
                    child: const Center(
                      child: Text("Log In", style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account ?  ", style: TextStyle(color: Colors.black, fontSize: 20)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const SignIn()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadiusDirectional.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 10.0,
                              ),
                            ]
                        ),
                        width: 90,
                        height: 50,
                        child: const Center(
                          child: Text("Sign In", style: TextStyle(fontSize: 20, color: Colors.black),),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
