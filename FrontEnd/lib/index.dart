import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'sign_in.dart';
import 'main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var alreadyLoggedIn = sharedPreferences.getString("username");
  runApp(MaterialApp(debugShowCheckedModeBanner: false,home: (alreadyLoggedIn == null) ? const SignIn() : const MainMenu()));
}
