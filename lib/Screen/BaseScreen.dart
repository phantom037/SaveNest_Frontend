import 'package:flutter/material.dart';
import 'package:jarvision/Screen/PaymentScreen.dart';
import 'package:jarvision/Screen/ProfileScreen.dart';
import 'package:jarvision/Screen/SettingScreen.dart';

import '../constant/ThemeColor.dart';
import 'CardScreen.dart';
import 'HomeScreen.dart';

class BaseScreen extends StatefulWidget {

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CardScreen(),
    PaymentScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home,), label: "Home",),
            BottomNavigationBarItem(
                icon: Icon(Icons.credit_card), label: "Cards"),
            BottomNavigationBarItem(
                icon: Icon(Icons.payments), label: "Send"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard), label: "Leaderboard")
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
    );
  }
}