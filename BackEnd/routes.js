const functions = require("./functions");
const express = require("express");

const router = express.Router();

router.post("/login", functions.login);
router.post("/signin", functions.signin);

router.post("/addfriend", functions.addfriend);
router.post("/showfriend", functions.showfriend);
router.post("/findfriend", functions.findFriends);

router.post("/showgroup", functions.showGroup);
router.post("/showgroupbyid", functions.showGroupById);
router.post("/addgroup", functions.addGroup);
router.delete("/deletegroup",functions.deleteGroup);

router.post("/addexpense", functions.addExpense);
// router.post("/editexpense",functions);
router.delete("/deleteexpense", functions.deleteExpense);

router.post("/paymoney",functions.payMoney);

module.exports = router;
