const express = require("express");
const bodyparser = require("body-parser");
const mongoose = require("./dbConnect/dbConnect");
const routes = require("./routes");

const app = express();
const port = 3000;

app.use(bodyparser.json());
app.use("/", routes);

const books = [
  { id: 1, title: "Alice in Wonderland", author: "Lewis Carrol" },
  { id: 2, title: "Around the World in eighty days", author: "Jules Verne" },
  { id: 3, title: "Utopia", author: "Sir Thomas Moor" },
];

app.get("/api/books", (req, res) => {
  res.json(books);
});

app.listen(port, () => {
  console.log("Server Connected");
});
