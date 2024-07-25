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
    var response = await http.post(Uri.parse(showFriendUrl), headers: {"Content-Type": "application/json"}, body: jsonEncode(input));
    var jsonResponse = jsonDecode(response.body);
    friendList = jsonResponse["List"];
  }

  Future<List<dynamic>> findFriends(partialUserId) async {
    var input = {"partialUserId": partialUserId};
    var response = await http.post(Uri.parse(findFriendUrl),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(input));
    var jsonResponse = jsonDecode(response.body);
    return jsonResponse["search"];
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
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (context) {
                TextEditingController friendUsername = TextEditingController();
                bool alreadyFriend = false;
                bool thatsyou = false;
                List<dynamic> foundFriends = [];
                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Center(child: Text('Find your Friend')),
                      content: SizedBox(
                        width: 300,
                        height: 400,
                        child: Column(
                          children: [
                            TextField(
                              style: const TextStyle(fontSize: 23),
                              onChanged: (s) async {
                                foundFriends = await findFriends(s);
                                setState(() {});
                              },
                              controller: friendUsername,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.black,
                                ),
                                hintText: "Friend's Username",
                                hintStyle: const TextStyle(fontSize: 22),
                                errorText: thatsyou ? "That's You" : alreadyFriend ? "Already a Friend" : null,
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                            ),
                            Card(
                              color: Colors.white,
                              elevation: 10,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: foundFriends.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                        var username = sharedPreferences.getString("username");
                                        var input = ({
                                          "username": username,
                                          "friendUsername": foundFriends[index]["username"],
                                        });
                                        var response = await http.post(
                                            Uri.parse(addFriendUrl),
                                            headers: {
                                              "Content-Type": "application/json"
                                            },
                                            body: jsonEncode(input));
                                        var jsonResponse = jsonDecode(response.body);
                                        if (jsonResponse["message"] == "Already a Friend") {
                                          alreadyFriend = true;
                                          thatsyou = false;
                                          setState(() {});
                                        } else if (jsonResponse["message"] == "That's You"){
                                          print("true");
                                          thatsyou = true;
                                          alreadyFriend = false;
                                          setState(() {});
                                        }else if (jsonResponse["message"] == "Added Friend") {
                                          showFriends().then((value) {
                                            Navigator.pop(context);
                                          });
                                        }
                                      },
                                      child: Card(
                                          margin: const EdgeInsets.all(6),
                                          elevation: 20,
                                          shadowColor: Colors.grey,
                                          color: Colors.black,
                                          child: SizedBox(
                                              height: 35,
                                              child: Center(
                                                  child: Text(foundFriends[index]["username"],
                                                    style: const TextStyle(color: Colors.white, fontSize: 20),
                                                  )
                                              )
                                          )
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ]
                  );
                });
              });
          await showFriends();
          setState(() {});
        },
        label: const Text(
          "Add Friend",
          style: TextStyle(color: Colors.black, fontSize: 22),
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
