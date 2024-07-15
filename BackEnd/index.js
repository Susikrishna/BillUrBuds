const express = require("express");
const bodyparser = require("body-parser");
const mongoose = require("./dbConnect/dbConnect");
const routes = require("./routes");

const app = express();
const port = 3000;

app.use(bodyparser.json());
app.use("/", routes);

app.listen(port, () => {
  console.log("Server Connected");
});
