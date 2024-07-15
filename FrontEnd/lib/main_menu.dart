import 'package:bill_ur_buds/urls.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Main Menu Utilities/side_drawer.dart';
import 'Main Menu Utilities/add_group.dart';
import 'Main Menu Utilities/show_group.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<dynamic> groups = [];

  Future<void> showGroups() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var username = sharedPreferences.getString("username");
    var input = {"username": username};
    var response = await http.post(Uri.parse(showGroupUrl),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(input));
    var jsonResponse = jsonDecode(response.body);
    groups = jsonResponse["Data"];
    print(groups);
  }

  @override
  void initState() {
    showGroups().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        drawer: const Drawer(
          width: 300,
          backgroundColor: Colors.white,
          child: SideDrawer(),
        ),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          title: const Text(
            "BILL UR BUDS",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async{
            await Navigator.push(context, MaterialPageRoute(builder: (context) => AddGroup()));
            await showGroups();
            setState(() {});
          },
          backgroundColor: Colors.white,
          label: const Text(
            "Add Group",
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.black,
            size: 30,
          ),
        ),
        body: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () async{
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowGroup(groups[index])));
                  showGroups().then((value) {
                    setState(() {});
                  });
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shadowColor: Colors.grey,
                  elevation: 10,
                  child: SizedBox(
                    height: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.blue,
                              Colors.red,
                            ],
                          )),
                      child: Row(
                        children: [
                          Text(
                            "  ${groups[index]["groupName"]}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(3, 3),
                                  blurRadius: 5.0,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
