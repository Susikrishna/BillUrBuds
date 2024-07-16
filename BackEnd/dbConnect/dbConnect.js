const mongoose = require("mongoose");
const uri ="mongodb+srv://krishnasusi323:Susi%402006@cluster0.iasmne2.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

const connection = mongoose.createConnection(`mongodb://localhost:27017/`).on("open", () => {
    console.log("MongoDB Connected");
  })
  .on("error", () => {
    console.log("MongoDB Connection error");
  });

module.exports = connection;