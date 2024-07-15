const connection = require("../dbConnect/dbConnect");
const mongoose = require("mongoose");

const loginSchema = new mongoose.Schema({
  username: String,
  password: String,
});

const loginInfoModel = connection.model("loginInfo", loginSchema);
module.exports = loginInfoModel;
