import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:datepicker_dropdown/order_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widget/showAlert.dart';
import '../constant/ThemeColor.dart';
import 'BaseScreen.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';

class SignUpScreen extends StatefulWidget {
  //const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool showSpin = false, isVerified = false;
  String email = "", password = "", errorMessage = "", name = "";
  late SharedPreferences preferences;
  late User currentUser;
  Timer? timer;
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode nameFocusNode = FocusNode();
  String dob = "";

  void verifyEmail(User? user) {
    print("verifyEmail()");
    if (!(user!.emailVerified)) {
      user.sendEmailVerification();
      //Fluttertoast.showToast(msg: "Check your email to verify account");
      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified(user));
      setState(() {
        errorMessage = "Check email to verify!";
      });
    }
  }

  Future checkEmailVerified(User? user) async {
    //FirebaseAuth.instance.currentUser?.reload();

    print("Run checkEmailVerified");
    //print("verify: ${FirebaseAuth.instance.currentUser?.emailVerified}");
    setState(() {
      user!.reload();
      isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false; //user!.emailVerified;
    });

    if (isVerified) {
      timer?.cancel();
      checkLoginInStatus(user);
    }
  }

  Future checkLoginInStatus(User? user) async {
    preferences = await SharedPreferences.getInstance();
    print("checkLoginInStatus");

    ///Non Use Check if user has verify account
    if (user != null && !user.emailVerified) {
      //await user.sendEmailVerification();
      Fluttertoast.showToast(msg: "Check your email to verify account");
      print("Check your email to verify account");
    }

    ///Check if Register Success
    if (user != null) {
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("user")
          .where("id", isEqualTo: user.uid)
          .get();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      ///New User write data to Firebase
      if (documentSnapshots.length == 0) {
        String convert =
        user.displayName.toString().toLowerCase().replaceAll(' ', '');
        var arraySearchID = List.filled(convert.length, "");
        if (user.displayName != null) {
          for (int i = 0; i < convert.length; i++) {
            arraySearchID[i] =
                convert.substring(0, i + 1).toString().toLowerCase();
          }
        } else {
          String newUnknownUserName = "user" + user.uid.substring(0, 9);
          arraySearchID = new List.filled(newUnknownUserName.length, "");
          for (int i = 0; i < newUnknownUserName.length; i++) {
            arraySearchID[i] =
                newUnknownUserName.substring(0, i + 1).toString().toLowerCase();
          }
        }

        String userName = (user.displayName != null || user.displayName == "null")
            ? user.displayName.toString()
            : user.uid.substring(0, 9);
        FirebaseFirestore.instance.collection("user").doc(user.uid).set({
          "name": name != null
              ? name
              : "User " + user.uid.substring(0, 9),
          "userName": (user.displayName != null || user.displayName == "null")
              ? user.displayName
              : user.uid.substring(0, 9),
          "photoUrl": user.photoURL != null
              ? user.photoURL
              : "https://dlmocha.com/app/Ume-Talk/userDefaultAvatar.jpeg",
          "id": user.uid,
          "dob": dob,
          "createdAt": DateTime.now().toString(),
          "balance": 100000,
          "transactionList": null,
          "token": "No-data",
        });
        List<String> messagesList = ["You just received \$100,000 from the PiggyBank",
          "Elon Musk gave you \$100,000 for your Mars trip.", "Bill Gates threw you \$100,000",
          "The United Nations donated \$100,000 for you to save the world,"
              "Taylor Swift gave you \$100,000 to join her Worlds Tour", "\$100,000 just felt from the sky into your account",
          "Santa Claus delivered \$100,000 early this year", "Aliens transferred \$100,000 into your bank account as a peace offering"];
        int randomIndex = Random().nextInt(8);
        DateTime now = DateTime.now();

        String encodeStr = user.uid + now.toString();
        var appleInBytes = utf8.encode(encodeStr);
        String transactionid = sha256.convert(appleInBytes).toString();

        FirebaseFirestore.instance.collection("transaction").doc(transactionid).set({
          "id": transactionid,
          "senderId": "System-0000",
          "senderName": "Unknown",
          "receiverId": user.uid,
          "receiverName": userName,
          "description": messagesList[randomIndex],
          "amount": 100000,
          "time": now
        });
        List<String> transactions = [];
        transactions.add(transactionid);
        FirebaseFirestore.instance.collection("user").doc(user.uid).update({
          "transactionList": transactions,
        });
        //Write data to Local
        currentUser = user;

        await preferences.setString("id", currentUser.uid);
        await preferences.setString("name", name != null ? name : ("User " + user.uid.substring(0, 9)));
        await preferences.setString(
            "photoUrl",
            currentUser.photoURL.toString() != null
                ? currentUser.photoURL.toString()
                : "https://dlmocha.com/app/Ume-Talk/userDefaultAvatar.jpeg");
        await preferences.setString("about", "None");

        Fluttertoast.showToast(msg: "Register Success");
        await Future.delayed(const Duration(seconds: 3));
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return BaseScreen();
        }));
      }
      setState(() {
        showSpin = false;
      });
    } else {
      ///SignIn fail
      Fluttertoast.showToast(msg: "Fail to Register. Please try again.");
      setState(() {
        showSpin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [themeColor, subThemeColor],
                      stops: [0.7, 1.0],
                    )
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(
                      height: 150.0,
                    ),
                    const Flexible(child:
                    Text("SaveNest",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),)),
                    const SizedBox(
                      height: 100.0,
                    ),
                    TextField(
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.name,
                      onChanged: (value) {
                        name = value;
                      },
                      focusNode: nameFocusNode,
                      decoration: const InputDecoration(
                        hintText: "Full Name",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:  EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border:  OutlineInputBorder(
                          borderRadius:  BorderRadius.all(Radius.circular(19.0)),
                        ),
                        enabledBorder:  OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black45, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(19.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(19.0)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value;
                      },
                      focusNode: emailFocusNode,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:  EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border:  OutlineInputBorder(
                          borderRadius:  BorderRadius.all(Radius.circular(19.0)),
                        ),
                        enabledBorder:  OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black45, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(19.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(19.0)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      textAlign: TextAlign.start,
                      obscureText: true,
                      onChanged: (value) {
                        password = value;
                      },
                      focusNode: passwordFocusNode,
                      decoration: const InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius:  BorderRadius.all(Radius.circular(32.0)),
                        ),
                        enabledBorder:  OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black45, width: 1.0),
                          borderRadius:  BorderRadius.all(Radius.circular(19.0)),
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 2.0),
                          borderRadius:  BorderRadius.all(Radius.circular(19.0)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(color: Colors.white, borderRadius:  BorderRadius.all(Radius.circular(19.0))),
                      child: Center(child: Text("Enter Your Birthdate Below")),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      child: DropdownDatePicker(
                        boxDecoration: BoxDecoration(color: Colors.white),
                        dateformatorder: OrderFormat.YMD, // default is myd
                        inputDecoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 0),
                            ),
                            border: OutlineInputBorder(
                                )), // optional
                        isDropdownHideUnderline: true, // optional
                        isFormValidator: true, // optional
                        startYear: 1900, // optional
                        endYear: 2020, // optional
                        //width: 10, // optional
                        // selectedDay: 14, // optional
                        //selectedMonth: 10, // optional
                        //selectedYear: 1993, // optional
                        onChangedDay: (value) => dob += "$value",//print('onChangedDay: $value'),
                        onChangedMonth: (value) => dob += "$value-",//print('onChangedMonth: $value'),
                        onChangedYear: (value) => dob += "$value-", //print('onChangedYear: $value'),
                        //boxDecoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey, width: 1.0)), // optional
                        // showDay: false,// optional
                        dayFlex: 2,// optional
                        // locale: "zh_CN",// optional
                        hintDay: 'DD', // optional
                        hintMonth: 'MMM', // optional
                        hintYear: 'YYYY', // optional
                        // hintTextStyle: TextStyle(color: Colors.grey), // optional
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Center(child: showAlert(errorMessage)),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Material(
                          borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                          elevation: 5.0,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius: BorderRadius.circular(19.0),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(19.0),
                              onTap: () async {
                                setState(() {
                                  showSpin = true;
                                });
                                try {
                                  User? newUser = (await firebaseAuth.createUserWithEmailAndPassword(
                                      email: email, password: password)).user;
                                  if (newUser != null) {
                                    verifyEmail(newUser);

                                  }
                                  setState(() {
                                    showSpin = false;
                                  });
                                } on FirebaseAuthException catch (error) {
                                  print(error);
                                  switch (error.code) {
                                    case "invalid-email":
                                      errorMessage = "Email is badly formatted.";
                                      break;
                                    case "weak-password":
                                      errorMessage = "Password requires at least 6 letters.";
                                      break;
                                    case "email-already-in-use":
                                      errorMessage = "This email has already been used.";
                                      break;
                                    case "too-many-requests":
                                      errorMessage = "Too many requests. Try again later.";
                                      break;
                                    default:
                                      errorMessage = "An undefined Error happened.";
                                  }
                                  setState(() {
                                    Fluttertoast.showToast(msg: "Fail to register. Please try again.");
                                    showSpin = false;
                                  });
                                }
                              },
                              child: Container(
                                width: 150.0,
                                height: 50.0,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[ Container(
                          alignment: Alignment.center,
                          child: GestureDetector(
                              child: const Text(
                                "By continue you agree with",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              onTap: () {}),
                        ), GestureDetector(child:
                        const Text(" policy", style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w900,

                        ),),
                            onTap: (){})
                        ]),
                  ],
                ),
              ),
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 60,
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Have an account? ", style: TextStyle(fontSize: 15, color: Colors.white),),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return LoginScreen();
                              }));
                            }),
                      ),
                    ],),
                )),
          ]),
    );
  }
}
