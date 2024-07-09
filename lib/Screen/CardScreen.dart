import 'package:flutter/material.dart';

import '../Widget/myCard.dart';
import '../constant/AppTextstyle.dart';
import '../constant/ThemeColor.dart';
import '../data/CardData.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Cards",
          style: TextStyle(
            fontFamily: "Poppins",
            color: kPrimaryColor,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.notifications_active_outlined,
                color: Colors.black,
                size: 27,
              ),
              onPressed: () {})
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: ListView.separated(
                shrinkWrap: true,
                itemCount: myCards.length,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 20,
                  );
                },
                itemBuilder: (context, index) {
                  return MyCard(
                    card: myCards[index],
                  );
                }),
          ),
          CircleAvatar(
            radius: 40,
            child: Icon(Icons.add, size: 50),
          ),
          SizedBox(height: 10),
          Text(
            "Add Card",
            style: ApptextStyle.LISTTILE_TITLE,
          )
        ],
      ),
    );
  }
}