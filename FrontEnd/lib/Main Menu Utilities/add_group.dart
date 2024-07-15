import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:bill_ur_buds/urls.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  TextEditingController groupNameController = TextEditingController();
  List<dynamic> friendsList = [];
  List<bool> chosen = [];
  var validGroupName = true;

  Future<void> showFriends() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var input = ({"username": sharedPreferences.getString("username")});
    var response = await http.post(Uri.parse(showFriendUrl),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(input));
    var jsonResponse = jsonDecode(response.body);
    friendsList = jsonResponse["List"];
    chosen = List.filled(friendsList.length, false);
  }

  @override
  void initState() {
    super.initState();
    showFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Your Group",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 1),
            const Text(
              " Group Name:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.8, 1.8),
                    blurRadius: 5.0,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              style: const TextStyle(color: Colors.white, fontSize: 23),
              controller: groupNameController,
              decoration: InputDecoration(
                errorText: validGroupName ? null : "Group Name cannot be empty",
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 3.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
                child: GestureDetector(
              onTap: () async {
                var dummy = await Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => AddMembers(friendsList, chosen)));
                if (dummy != null) {
                  dummy = chosen;
                }
                setState(() {});
              },
              child: const Card(
                elevation: 10,
                shadowColor: Colors.white,
                color: Colors.white,
                child: SizedBox(
                    width: 150,
                    height: 42,
                    child: Center(
                        child: Text(
                      "Add Members",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ))),
              ),
            )),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: friendsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (chosen[index]) {
                      return Card(
                        margin: const EdgeInsets.all(6),
                        shadowColor: Colors.grey,
                        elevation: 10,
                        child: SizedBox(
                          height: 40,
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
                                  "   ${friendsList[index]}",
                                  style: const TextStyle(fontSize: 23),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    chosen[index] = false;
                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.close_sharp,
                                    size: 26,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
            ),
            Center(
                child: GestureDetector(
              onTap: () async {
                if (groupNameController.text == "") {
                  validGroupName = false;
                  setState(() {});
                } else {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  List<String> members = [];
                  var username = sharedPreferences.getString("username");
                  for (int i = 0; i < chosen.length; i++) {
                    if (chosen[i]) {
                      members.add(friendsList[i]);
                    }
                  }
                  members.insert(0, username!);
                  var input = ({
                    "groupName": groupNameController.text,
                    "members": members,
                  });
                  var response = await http.post(Uri.parse(addGroupUrl),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode(input));
                  var jsonResponse = jsonDecode(response.body);
                  if (jsonResponse["message"] == "Group Added") {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Card(
                elevation: 10,
                shadowColor: Colors.white,
                color: Colors.white,
                child: SizedBox(
                    width: 150,
                    height: 44,
                    child: Center(
                        child: Text(
                      "Create Group",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ))),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class AddMembers extends StatefulWidget {
  const AddMembers(this.friendsList, this.chosen, {super.key});

  final List<dynamic> friendsList;
  final List<bool> chosen;

  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add your friends"),
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: widget.friendsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        widget.chosen[index] =
                            widget.chosen[index] ? false : true;
                        setState(() {});
                      },
                      child: Card(
                        shadowColor:
                            widget.chosen[index] ? Colors.green : Colors.red,
                        color: widget.chosen[index] ? Colors.green : Colors.red,
                        elevation: 30,
                        child: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(widget.friendsList[index].toString(),
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Center(
                child: GestureDetector(
              onTap: () async {
                Navigator.pop(context, widget.chosen);
                setState(() {});
              },
              child: const Card(
                elevation: 5,
                color: Colors.white,
                child: SizedBox(
                    width: 60,
                    height: 40,
                    child: Center(
                        child: Text(
                      "OK",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ))),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
