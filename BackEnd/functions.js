const UserInfoModel = require("./models/userInfo");
const friendInfoModel = require("./models/friendinfo");
const groupInfoModel = require("./models/groupInfo");

exports.login = async (req, res) => {
  const { username, password } = req.body;
  let f = await UserInfoModel.findOne({ username: username });
  if (f != null) {
    if (f.password == password) {
      res.json({ message: "success" });
    } else {
      res.json({ message: "password" });
    }
  } else {
    res.json({ message: "username" });
  }
};

exports.signin = async (req, res) => {
  try {
    const { username, password } = req.body;
    if ((await UserInfoModel.findOne({ username: username })) != null) {
      res.json({ message: "username" });
    } else {
      const newUser = new UserInfoModel({
        username: username,
        password: password,
      });
      const friends = new friendInfoModel({
        username: username,
        friends: [],
      });
      await newUser.save();
      await friends.save();
      res.json({ message: "success" });
    }
  } catch (err) {
    res.json({ message: err });
  }
};

exports.addfriend = async (req, res) => {
  const { username, friendUsername } = req.body;
  if (username == friendUsername) {
    res.json({ message: "That's You" });
  } else if (
    (await friendInfoModel.findOne({
      username: username,
      friends: friendUsername,
    })) != null
  ) {
    res.json({ message: "Already a Friend" });
  } else {
    if ((await UserInfoModel.findOne({ username: friendUsername })) != null) {
      await friendInfoModel.updateOne(
        { username: username },
        { $push: { friends: friendUsername } }
      );
      await friendInfoModel.updateOne(
        { username: friendUsername },
        { $push: { friends: username } }
      );
      res.json({ message: "Added Friend" });
    }
  }
};

exports.showfriend = async (req, res) => {
  let { username } = req.body;
  let search = await friendInfoModel.findOne({ username: username });
  res.json({ List: search["friends"] });
};

exports.findFriends = async (req, res) => {
  let { partialUserId } = req.body;
  let search;
  if (partialUserId != "") {
    search = await UserInfoModel.find(
      { username: { $regex: new RegExp(`^${partialUserId}`) } },
      { username: 1 }
    ).limit(5);
  } else {
    search = [];
  }
  res.json({ search: search });
};

exports.addGroup = async (req, res) => {
  let { groupName, members } = req.body;
  let newGroup = new groupInfoModel({
    groupName: groupName,
    members: members,
    expenses: [],
    balances: [],
    toPay: [],
    paid: Array.from({ length: members.length }, (_) =>
      new Array(members.length).fill(0)
    ),
  });
  newGroup["balances"].length = members.length;
  newGroup["balances"].fill(0);
  await newGroup.save();
  res.json({ message: "Group Added" });
};

exports.showGroup = async (req, res) => {
  let { username } = req.body;
  let search = await groupInfoModel.find({ members: username });
  res.json({ Data: search });
};

exports.deleteGroup = async (req, res) => {
  let { _id } = req.body;
  await groupInfoModel.deleteOne({ _id: _id });
  res.json({ message: "Deleted" });
};

exports.addExpense = async (req, res) => {
  let { _id, expenseName, expense } = req.body;

  let groupInfo = await groupInfoModel.findOne(
    { _id: _id },
    { balances: 1, paid: 1 }
  );
  let balances = groupInfo["balances"];
  let toPay = Array.from({ length: balances.length }, (_) =>
    new Array(balances.length).fill(0)
  );

  //Calculating parameters needed for changing balance
  let included = expense.length;
  let money = 0;
  for (let i = 0; i < expense.length; i++) {
    if (expense[i] == -1) {
      included--;
    } else if (expense[i] > 0) {
      money += expense[i];
    }
  }
  money = money / included;
  money = Math.round(money * 100) / 100;

  //Changing Balances
  for (let i = 0; i < balances.length; i++) {
    if (expense[i] != -1) {
      balances[i] += expense[i] - money;
      balances[i] = Math.round(balances[i] * 100) / 100;
    }
  }

  //Changing toPay
  function compare1(a, b) {
    return a[0] - b[0];
  }
  function compare2(a, b) {
    return b[0] - a[0];
  }
  var Owe = [];
  var Lend = [];
  for (let i = 0; i < balances.length; i++) {
    if (balances[i] > 0) {
      Lend.push([balances[i], i]);
      Lend.sort(compare1);
    } else if (balances[i] < 0) {
      Owe.push([balances[i], i]);
      Owe.sort(compare2);
    }
  }

  while (Owe.length != 0 && Lend.length != 0) {
    var positive = Lend.pop();
    var negative = Owe.pop();
    if (-negative[0] > positive[0]) {
      Owe.push([negative[0] + positive[0], negative[1]]);
      Owe.sort(compare2);
      toPay[negative[1]][positive[1]] = Math.round(-positive[0] * 100) / 100;
      toPay[positive[1]][negative[1]] = Math.round(positive[0] * 100) / 100;
    } else if (-negative[0] < positive[0]) {
      Lend.push([negative[0] + positive[0], positive[1]]);
      Lend.sort(compare1);
      toPay[negative[1]][positive[1]] = Math.round(negative[0] * 100) / 100;
      toPay[positive[1]][negative[1]] = Math.round(-negative[0] * 100) / 100;
    } else {
      toPay[negative[1]][positive[1]] = Math.round(-positive[0] * 100) / 100;
      toPay[positive[1]][negative[1]] = Math.round(positive[0] * 100) / 100;
    }
  }
  //Adding the new expense
  let newExpense = {
    expenseName: expenseName,
    expense: expense,
  };
  await groupInfoModel.updateOne(
    { _id: _id },
    {
      $push: { expenses: newExpense },
      $set: { balances: balances, toPay: toPay },
    }
  );
  res.json({ message: "Added" });
};

exports.deleteExpense = async (req, res) => {
  var { _id, data } = req.body;

  //Changing Balances
  let groupInfo = await groupInfoModel.findOne({ _id: _id }, { balances: 1 });
  let balances = groupInfo["balances"];
  let included = balances.length;
  let money = 0;
  for (let i = 0; i < balances.length; i++) {
    if (data["expense"][i] == -1) {
      included--;
    } else if (data["expense"][i] > 0) {
      money += data["expense"][i];
    }
  }
  money = money / included;
  money = Math.round(money * 100) / 100;
  for (let i = 0; i < balances.length; i++) {
    if (data["expense"][i] != -1) {
      balances[i] -= data["expense"][i] - money;
      balances[i] = Math.round(balances[i] * 100) / 100;
    }
  }

  //Updating toPay
  let toPay = Array.from({ length: balances.length }, (_) =>
    new Array(balances.length).fill(0)
  );
  function compare1(a, b) {
    return a[0] - b[0];
  }
  function compare2(a, b) {
    return b[0] - a[0];
  }
  var Owe = [];
  var Lend = [];
  for (let i = 0; i < balances.length; i++) {
    if (balances[i] > 0) {
      Lend.push([balances[i], i]);
      Lend.sort(compare1);
    } else if (balances[i] < 0) {
      Owe.push([balances[i], i]);
      Owe.sort(compare2);
    }
  }

  while (Owe.length != 0 && Lend.length != 0) {
    var positive = Lend.pop();
    var negative = Owe.pop();
    if (-negative[0] > positive[0]) {
      Owe.push([negative[0] + positive[0], negative[1]]);
      Owe.sort(compare2);
      toPay[negative[1]][positive[1]] = Math.round(-positive[0] * 100) / 100;
      toPay[positive[1]][negative[1]] =Math.round(positive[0] * 100) / 100;
    } else if (-negative[0] < positive[0]) {
      Lend.push([negative[0] + positive[0], positive[1]]);
      Lend.sort(compare1);
      toPay[negative[1]][positive[1]] = Math.round(negative[0] * 100) / 100;
      toPay[positive[1]][negative[1]] = Math.round(-negative[0] * 100) / 100;
    } else {
      toPay[negative[1]][positive[1]] = Math.round(-positive[0] * 100) / 100;
      toPay[positive[1]][negative[1]] = Math.round(positive[0] * 100) / 100;
    }
  }

  //Deleting the expense
  await groupInfoModel.updateOne(
    { _id: _id },
    { $pull: { expenses: data }, $set: { balances: balances, toPay: toPay } }
  );
  res.json({ message: "Deleted" });
};

exports.payMoney = async (req, res) => {
  let { _id, index1, index2, amount } = req.body;
  var data = await groupInfoModel.findOne(
    { _id: _id },
    { toPay: 1, balances: 1, paid: 1 }
  );
  var toPay = data["toPay"];
  var balances = data["balances"];
  var paid = data["paid"];
  balances[index1] += amount;
  balances[index2] -= amount;
  toPay[index1][index2] += amount;
  toPay[index1][index2] = Math.round(toPay[index1][index2] * 100) / 100;
  toPay[index2][index1] -= amount;
  toPay[index2][index1] = Math.round(toPay[index2][index1] * 100) / 100;
  paid[index1][index2] -= amount;
  paid[index1][index2] = Math.round(paid[index1][index2] * 100) / 100;
  paid[index2][index1] += amount;
  paid[index2][index1] = Math.round(paid[index2][index1] * 100) / 100;
  await groupInfoModel.updateOne(
    { _id: _id },
    {
      $set: { balances: balances, toPay: toPay, paid: paid },
    }
  );
  res.json({ message: "Done" });
};

exports.showGroupById = async (req, res) => {
  let { _id } = req.body;
  var data = await groupInfoModel.findOne({ _id: _id });
  res.json({ Data: data });
};