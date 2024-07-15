import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'main_menu.dart';
import "package:shared_preferences/shared_preferences.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var alreadyLoggedIn = sharedPreferences.getString("username");
  runApp(MaterialApp(debugShowCheckedModeBanner: false,home: (alreadyLoggedIn == null) ? const SignIn() : const MainMenu()));
}
