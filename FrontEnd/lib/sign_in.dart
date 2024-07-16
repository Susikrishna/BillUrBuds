import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'log_in.dart';
import 'urls.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var invalidPassword = false;
  var invalidUsername = false;
  var usernameAlreadyExists = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text("SIGN IN", style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text("Please, Sign Up if you don't have a account", style: TextStyle(color: Colors.black, fontSize: 18)),
                const SizedBox(height: 30),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    hintText: "Username",
                    errorText: usernameAlreadyExists ? "Username already exists. Try another!!" : invalidUsername ? "Cannot be empty" : null,
                    errorStyle: const TextStyle(color: Colors.red),
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
                    hintText: "Password",
                    errorText: invalidPassword ? "Cannot be empty" : null,
                    errorStyle: const TextStyle(color: Colors.red),
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
                        invalidUsername = true;
                      } else {
                        invalidUsername = false;
                      }
                      if (passwordController.text.toString() == "") {
                        invalidPassword = true;
                      } else {
                        invalidPassword = false;
                      }
                      setState(() {});
                    } else {
                      var input = ({
                        "username": usernameController.text,
                        "password": passwordController.text,
                      });
                      var response = await http.post(Uri.parse(signUrl),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(input));
                      var jsonResponse = jsonDecode(response.body);
                      if (jsonResponse["message"] == "success") {
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      } else if (jsonResponse["message"] == "username") {
                        usernameController.clear();
                        passwordController.clear();
                        invalidPassword = (invalidUsername=false);
                        usernameAlreadyExists = true;
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
                    width: 100,
                    height: 50,
                    child: const Center(
                      child: Text("Sign Up", style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account ?  ",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
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
                            ]),
                        width: 80,
                        height: 50,
                        child: const Center(
                          child: Text(
                            "Log In",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
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