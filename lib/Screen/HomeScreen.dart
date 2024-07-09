import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widget/myCard.dart';
import '../Widget/transactionCard.dart';
import '../constant/AppTextstyle.dart';
import '../constant/ThemeColor.dart';
import '../data/CardData.dart';
import '../data/TransactionData.dart';
import 'LoginScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late SharedPreferences preference;
  String photoUrl = "https://static.vecteezy.com/system/resources/previews/004/439/693/original/avatar-doodle-profile-cartoon-character-vector.jpg";
  String id = "";
  List<TransactionModel> transactionList = List<TransactionModel>.from(myTransactions);

  @override
  void initState(){
    super.initState();
    loadAsset();
  }

  Future loadAsset() async{
    preference = await SharedPreferences.getInstance();
    setState(() {
      photoUrl = preference.getString("photoUrl").toString();
      id = preference.getString("id").toString();

    });
    await loadTransactionList();
  }

  Future loadTransactionList() async{
    try{
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('id', isEqualTo: id)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userSnapshot.docs.first;
        List<dynamic> transactions = userDoc['transactionList'];
        print(transactions);
        for(var item in transactions.reversed){
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('transaction')
              .where('id', isEqualTo: item)
              .get();
          DocumentSnapshot transactionDoc = userSnapshot.docs.first;
          //print(transactionDoc);
          String send_receive_id = transactionDoc["senderId"];
          //print("send_receive_id: $send_receive_id");
          double amount = transactionDoc["amount"].toDouble();
          String avatar = "https://static.vecteezy.com/system/resources/previews/028/228/713/non_2x/gold-coins-cash-money-in-piles-cartoon-illustration-3d-dollar-coins-flat-icon-outline-vector.jpg";
          String content = send_receive_id == id ? "You sent" : "You received";
          Color contentColor = send_receive_id == id ? Colors.red : Colors.green;
          setState(() {
            transactionList.insert(0, TransactionModel(avatar: avatar, name: content, amount: amount, color: contentColor));
          });
          print(transactionList);
        }
      }
    }catch (e) {print(e);}
  }

  Future logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();

    ///Todo Delete this line for Android await googleSignIn.signOut();
    await googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }), (Route<dynamic> route) => false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Bank",
          style: TextStyle(
            fontFamily: "Poppins",
            color: kPrimaryColor,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage:
            NetworkImage(photoUrl),
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.notifications_active_outlined,
                color: Colors.black,
                size: 27,
              ),
              onPressed: (){})
        ],
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                child: ListView.separated(
                    physics: ClampingScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 10,
                      );
                    },
                    itemCount: myCards.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return MyCard(
                        card: myCards[index],
                      );
                    }),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Recent Transactions",
                style: ApptextStyle.BODY_TEXT,
              ),
              SizedBox(
                height: 15,
              ),
              ListView.separated(
                  itemCount: transactionList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 10,
                    );
                  },
                  itemBuilder: (context, index) {
                    return TransactionCard(transaction: transactionList[index]);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
