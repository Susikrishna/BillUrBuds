const connection = require("../dbConnect/dbConnect");
const mongoose = require("mongoose");

const groupInfoSchema = new mongoose.Schema({
  groupName: String,
  members: [String],
  expenses: [{ expenseName: String, expense: [Number] }],
  balances: [Number],
  toPay: [[Number]],
  paid: [[Number]]
});

const groupInfoModel = connection.model("groupInfo", groupInfoSchema);
module.exports = groupInfoModel;
