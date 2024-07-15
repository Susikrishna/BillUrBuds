import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../urls.dart';

class FriendsMenu extends StatefulWidget {
  const FriendsMenu({super.key});

  @override
  State<FriendsMenu> createState() => _FriendsMenuState();
}

class _FriendsMenuState extends State<FriendsMenu> {
  List<dynamic> friendList = [];

  Future<void> showFriends() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var input = ({"username": sharedPreferences.getString("username")});
    var response = await http.post(Uri.parse(showFriendUrl),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(input));
    var jsonResponse = jsonDecode(response.body);
    friendList = jsonResponse["List"];
  }

  @override
  void initState() {
    super.initState();
    showFriends().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () {
          TextEditingController friendUsername = TextEditingController();
          bool validFriend = true;
          bool alreadyFriend = false;
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                      title: const Center(child: Text('Find your Friend')),
                      content: SizedBox(
                        width: 300,
                        height: 250,
                        child: Column(
                          children: [
                            TextField(
                              // onChanged: (s) {},
                              controller: friendUsername,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search,color: Colors.black,),
                                hintText: "Friend's Username",
                                hintStyle: const TextStyle(fontSize: 22),
                                errorText: alreadyFriend ? "Already a Friend" : validFriend ? null : "Friend Doesn't exist",
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('OK'),
                          onPressed: () async {
                            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                            var username = sharedPreferences.getString("username");
                            var input = ({
                              "username": username,
                              "friendUsername": friendUsername.text,
                            });
                            var response = await http.post(
                                Uri.parse(addFriendUrl),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode(input));
                            var jsonResponse = jsonDecode(response.body);
                            if (jsonResponse["message"] == "Friend Already exists") {
                              alreadyFriend = true;
                              setState(() {});
                            } else if (jsonResponse["message"] == "Friend Username Wrong") {
                              validFriend = false;
                              alreadyFriend = false;
                              setState(() {});
                            } else if (jsonResponse["message"] == "Added Friend") {
                              showFriends();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ]
              )
          );
          setState(() {});
        },
        label: const Text(
          "Add Friend",
          style: TextStyle(color: Colors.black,fontSize: 22),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.black,
          size: 26,
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Your Friends",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
            itemCount: friendList.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 10,
                color: Colors.white,
                shadowColor: Colors.white,
                child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      friendList[index],
                      style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
