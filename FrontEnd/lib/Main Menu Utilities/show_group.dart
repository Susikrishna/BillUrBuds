import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:bill_ur_buds/urls.dart';
import 'add_expense.dart';

//ignore: must_be_immutable
class ShowGroup extends StatefulWidget {
  ShowGroup(this.groupInfo, {super.key});
  var groupInfo = {};

  @override
  State<ShowGroup> createState() => _ShowGroupState();
}

class _ShowGroupState extends State<ShowGroup> {
  var userIndex = -1;

  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      var username = instance.getString("username");
      var members = widget.groupInfo["members"];
      for (var i = 0; i < members.length; i++) {
        if (username == members[i]) {
          userIndex = i;
          break;
        }
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          title: Text(
            widget.groupInfo["groupName"],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                  icon: Icon(
                    Icons.money_sharp,
                    color: Colors.white,
                    size: 28,
                  ),
                  child: Text("Expenses", style: TextStyle(color: Colors.white, fontSize: 18))
              ),
              Tab(
                  icon: Icon(
                    Icons.balance,
                    color: Colors.white,
                    size: 28,
                  ),
                  child: Text("Balances", style: TextStyle(color: Colors.white, fontSize: 18))
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            var data = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpense(widget.groupInfo)));
            if (data != null) {
              var input = {
                "_id" : widget.groupInfo["_id"],
                "expenseName": data[0],
                "expense": data[1],
              };
              await http.post(Uri.parse(addExpenseUrl),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode(input)
              );

              var input1 = {"_id": widget.groupInfo["_id"],};
              var response = await http.post(
                Uri.parse(showGroupByIdUrl),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(input1),
              );
              var jsonResponse = jsonDecode(response.body);
              widget.groupInfo = jsonResponse["Data"];
              setState(() {});
            }
          },
          backgroundColor: Colors.white,
          label: const Text("Add Expense", style: TextStyle(fontSize: 20, color: Colors.black),),
          icon: const Icon(
            Icons.add,
            color: Colors.black,
            size: 30,
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.groupInfo["expenses"].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        color: Colors.white,
                        elevation: 10,
                        shadowColor: Colors.white,
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 5,),
                                borderRadius: const BorderRadius.all(Radius.circular(12))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("For ${widget.groupInfo["expenses"][index]["expenseName"]}:", style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Icon(Icons.edit, color: Colors.black, size: 28),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        var input = {
                                          "_id": widget.groupInfo["_id"],
                                          "data": widget.groupInfo["expenses"][index],
                                        };
                                        await http.delete(
                                            Uri.parse(deleteExpenseUrl),
                                            headers: {"Content-Type": "application/json"},
                                            body: jsonEncode(input)
                                        );

                                        var input1 = {
                                          "_id": widget.groupInfo["_id"],
                                        };
                                        var response = await http.post(
                                          Uri.parse(showGroupByIdUrl),
                                          headers: {"Content-Type": "application/json"},
                                          body: jsonEncode(input1),
                                        );
                                        var jsonResponse = jsonDecode(response.body);
                                        widget.groupInfo = jsonResponse["Data"];
                                        setState(() {});
                                      },
                                      child: const Icon(Icons.delete, color: Colors.red, size: 28),
                                    )
                                  ],
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: widget.groupInfo["expenses"][index]["expense"].length,
                                    itemBuilder:
                                        (BuildContext context, int index1) {
                                      if (widget.groupInfo["expenses"][index]["expense"][index1] > 0) {
                                        return Text(
                                          "${widget.groupInfo["members"][index1]}: ₹${widget.groupInfo["expenses"][index]["expense"][index1]}",
                                          style: const TextStyle(fontSize: 23),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    })
                              ],
                            )));
                  }),
            ),
            if (widget.groupInfo["toPay"].length == 0 || userIndex == -1)
              const SizedBox.shrink()
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.groupInfo["members"].length,
                        itemBuilder: (BuildContext context, int index) {
                          if (widget.groupInfo["toPay"][userIndex][index] > 0) {
                            return Card(
                              elevation: 10,
                              color: Colors.white,
                              shadowColor: Colors.white,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black, width: 5,),
                                    borderRadius: const BorderRadius.all(Radius.circular(12))
                                ),
                                child: Text(
                                    "You Lent ${widget.groupInfo["members"][index]} ₹${widget.groupInfo["toPay"][userIndex][index]}",
                                    style: const TextStyle(color: Colors.black, fontSize: 23)),
                              ),
                            );
                          } else if (widget.groupInfo["toPay"][userIndex][index] < 0) {
                            return Card(
                              elevation: 10,
                              color: Colors.white,
                              shadowColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black, width: 5,),
                                    borderRadius: const BorderRadius.all(Radius.circular(12))
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Text(
                                        "You Owe ${widget.groupInfo["members"][index]} ₹${-widget.groupInfo["toPay"][userIndex][index]}",
                                        style: const TextStyle(color: Colors.black, fontSize: 23)),
                                    const SizedBox(height: 5),
                                    GestureDetector(
                                      onTap: () {
                                        TextEditingController amountController = TextEditingController();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                                  backgroundColor: Colors.black,
                                                  title: const Text("Settle Up", style: TextStyle(color: Colors.white)),
                                                  content: TextField(
                                                      style: const TextStyle(color: Colors.white, fontSize: 20),
                                                      keyboardType: TextInputType.number,
                                                      controller: amountController,
                                                      decoration: InputDecoration(
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: const BorderSide(color: Colors.white, width: 3.5),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                      )),
                                                  actions: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: Colors.black,
                                                              width: 5,
                                                            ),
                                                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                            color: Colors.white),
                                                        child: const Text("Cancel", style: TextStyle(fontSize: 20)),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        if (amountController.text != "") {
                                                          var input = {
                                                            "_id": widget.groupInfo["_id"],
                                                            "index1": userIndex,
                                                            "index2": index,
                                                            "amount": int.parse(amountController.text)
                                                          };
                                                          await http.post(
                                                              Uri.parse(payMoneyUrl),
                                                              headers: {"Content-Type": "application/json"},
                                                              body: jsonEncode(input)
                                                          );
                                                          var input1 = {
                                                            "_id": widget.groupInfo["_id"],
                                                          };
                                                          var response = await http.post(Uri.parse(showGroupByIdUrl),
                                                            headers: {"Content-Type": "application/json"},
                                                            body: jsonEncode(input1),
                                                          );
                                                          var jsonResponse = jsonDecode(response.body);
                                                          widget.groupInfo = jsonResponse["Data"];
                                                          setState(() {});
                                                          Navigator.pop(context);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: Colors.black,
                                                              width: 5,
                                                            ),
                                                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                            color: Colors.white
                                                        ),
                                                        child: const Text("Ok", style: TextStyle(fontSize: 20),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 5,
                                            ),
                                            borderRadius: const BorderRadius.all(Radius.circular(12))
                                        ),
                                        child: const Text("Settle Up", style: TextStyle(color: Colors.white, fontSize: 20)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.groupInfo["members"].length,
                        itemBuilder: (BuildContext context, int index) {
                          if(widget.groupInfo["paid"][userIndex][index]>0){
                            return Card(
                              color: Colors.black,
                              elevation: 10,
                              shadowColor: Colors.grey,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text("${widget.groupInfo["members"][index]} paid you ₹${widget.groupInfo["paid"][userIndex][index]}",style: const TextStyle(color: Colors.white,fontSize: 22),)),
                              ),
                            );
                          }
                          else if(widget.groupInfo["paid"][userIndex][index]<0){
                            return Card(
                              color: Colors.black,
                              elevation: 10,
                              shadowColor: Colors.grey,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text("You paid ₹${-widget.groupInfo["paid"][userIndex][index]} to ${widget.groupInfo["members"][index]}",style: const TextStyle(color: Colors.white,fontSize: 22))),
                              ),
                            );
                          }
                          else{
                            return const SizedBox.shrink();
                          }
                        }
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
