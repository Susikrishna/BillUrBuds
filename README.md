# BillUrBuds
An application to split bills among friends to settle up money within groups.

<p>
  It currently runs locally.
  
  It uses Flutter for frontend, ExpressJs for backend and MongoDb for database.
</p>

<h2>
  To make it run in your local system make sure to:
</h2>

<ul>
  <li>Change the 'baseIp'(It's a variable in Frontend/lib/urls.dart) to your localhost IP address which is your wifi's ip address.</li>
  <li>Download mongoDb community edition and run the mongodb community server from the terminal. You could use any other Mongodb server too, but make sure to change 'uri' in dbConnect/dbConnect.js </li>
</ul>

<p>
  After starting the app, its the same as always, you need to create a account. Then Log in to continue.
  
  Then to create a group you could the 'Add Group' Button in the Main Menu. Your friends are also required to create a account, if you want to include them to be in a group.
  
  To enter the group, you just need to tap on the card. The group has two menus, one is expenses, the other is balances. The Expense Menu stores the different expenses that your group spends. The Balances Menu shows the money that you owe or others owe you. 
  
  The debt is collapsed multiple people to reduce the number of transactions. 
  
  Each expense assumes that the group members has equal share in bills (i.e let there be 4 people a,b,c,d, if for a bill 'a' pays ₹1000 then each friend's share in the bill is ₹250). In each expense you can also choose the members whom you want to be part of that expense.
</p>
