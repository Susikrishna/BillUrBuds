const mongoose = require("mongoose");
var uri = `mongodb://localhost:27017/`;
const connection = mongoose.createConnection(uri).on("open", () => {
    console.log("MongoDB Connected");
  })
  .on("error", () => {
    console.log("MongoDB Connection error");
  });

module.exports = connection;