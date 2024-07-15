const connection = require("../dbConnect/dbConnect");
const mongoose = require("mongoose");

const friendInfoSchema = new mongoose.Schema({
  username: String,
  friends: [String],
});

const friendInfoModel = connection.model("Friends", friendInfoSchema);
module.exports = friendInfoModel;