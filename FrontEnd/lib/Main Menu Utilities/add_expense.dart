import 'package:flutter/material.dart';

//ignore: must_be_immutable
class AddExpense extends StatefulWidget {
  AddExpense(this.groupInfo, {super.key});

  var groupInfo = {};

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  var validExpenseName = true;
  TextEditingController expenseName = TextEditingController();
  List<bool?> included = [];
  List<TextEditingController> controller = [];
  List<int> expense = [];

  @override
  void initState() {
    controller = List.generate(widget.groupInfo["members"].length, (i) => TextEditingController(text: "0"));
    expense = List.filled(widget.groupInfo["members"].length, 0, growable: false);
    included = List.filled(widget.groupInfo["members"].length, true, growable: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "ADD YOUR EXPENSE",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(" Expense Name:",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              style: const TextStyle(color: Colors.white, fontSize: 21),
              controller: expenseName,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.white, width: 3.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  errorText: validExpenseName ? null : "Name is necessary",
                  errorStyle: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 20),
            ListView.builder(
                shrinkWrap: true,
                itemCount: widget.groupInfo["members"].length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.white,
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          Checkbox(
                            value: included[index],
                            onChanged: (bool? value) {
                              setState(() {
                                included[index] = value;
                                if(value ?? true){
                                  controller[index].text = "0";
                                }
                                else{
                                  controller[index].text = "Excluded";
                                  expense[index] = -1;
                                }
                              });
                            },
                          ),
                          Text(
                            "${widget.groupInfo["members"][index]}",
                            style: const TextStyle(
                                fontSize: 21,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 150,
                            height: 44,
                            child: TextField(
                              enabled: included[index],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 21),
                              keyboardType: TextInputType.number,
                              controller: controller[index],
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.currency_rupee,
                                  size: 28,
                                  color: Colors.black,
                                ),
                                fillColor: Colors.grey[800],
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 3.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
            Center(
                child: GestureDetector(
              onTap: () {
                if (expenseName.text == "") {
                  validExpenseName = false;
                  setState(() {});
                } else {
                  for (int i = 0; i < controller.length; i++) {
                    if(included[i] ?? true){
                      expense[i] = int.parse(controller[i].text);
                    }
                  }
                  Navigator.pop(context, [expenseName.text, expense]);
                }
              },
              child: SizedBox(
                width: 50,
                height: 40,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text(
                        "OK",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    )),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
