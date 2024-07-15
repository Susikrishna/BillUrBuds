import 'dart:io';
import 'package:flutter/material.dart';
import '../log_in.dart';
import 'friends_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String username = " ";

  @override
  initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(username,style: const TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold)),
          accountEmail: null,
        ),
        ListTile(
          leading: const Icon(Icons.person,size: 28,),
          title: const Text("Friends",style: TextStyle(fontSize: 23),),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => (const FriendsMenu())));
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings,size: 28,),
          title: const Text("Settings",style: TextStyle(fontSize: 23)),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.padding,size: 28,),
          title: const Text("Policies",style: TextStyle(fontSize: 23)),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.logout,size: 28,),
          title: const Text("Log Out",style: TextStyle(fontSize: 23)),
          onTap: () async {
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            sharedPreferences.remove("username");
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app_rounded,size: 28,),
          title: const Text("Exit",style: TextStyle(fontSize: 23)),
          onTap: () {
            exit(0);
          },
        ),
      ],
    );
  }
}
