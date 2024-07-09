import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  double _balance = 0.0;
  late SharedPreferences preference;
  String id = "", userName = "";

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
  }

  Future<void> _fetchUserBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Replace 'currentUserId' with the actual current user's ID
      preference = await SharedPreferences.getInstance();
      id = preference.getString("id").toString();
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(id)
          .get();

      if (userDoc.exists) {
        setState(() {
          _balance = userDoc['balance'].toDouble();
        });
      } else {
        setState(() {
          _errorMessage = 'User not found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMoney() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      String username = _usernameController.text.trim();
      double amount = double.parse(_amountController.text.trim());

      try {
        // Search for the user in Firebase
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('userName', isEqualTo: username)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;
          double newReceiverBalance = userDoc['balance'].toDouble();
          String receiverId = userDoc['id'];
          newReceiverBalance += amount;
          double newSenderBalance = _balance -= amount;
          setState(() {
            _balance -= amount;
          });

          DateTime now = DateTime.now();
          String encodeStr = id + now.toString();
          var appleInBytes = utf8.encode(encodeStr);
          String transactionid = sha256.convert(appleInBytes).toString();

          //Sender transaction handler
          try {
            List<dynamic> senderTransactionList = userDoc['transactionList'];
            senderTransactionList.insert(0, transactionid);
            await FirebaseFirestore.instance.collection("user").doc(id).update({
              "balance": newSenderBalance,
              "transactionList": senderTransactionList
            });
          } catch (e){}

          try {
            //Receiver transaction handler
            QuerySnapshot receiverSnapshot = await FirebaseFirestore.instance
                .collection('user')
                .where('id', isEqualTo: receiverId)
                .get();
            DocumentSnapshot receiverDoc = receiverSnapshot.docs.first;
            List<
                dynamic> receiverTransactionList = receiverDoc['transactionList'];
            receiverTransactionList.insert(0, transactionid);
            await FirebaseFirestore.instance.collection("user")
                .doc(receiverId)
                .update({
              "balance": newReceiverBalance,
              "transactionList": receiverTransactionList
            });
          } catch (e){}



          FirebaseFirestore.instance.collection("transaction").doc(transactionid).set({
            "id": transactionid,
            "senderId": id,
            "senderName": "XXXXXXXXXXXXX",
            "receiverId": receiverId,
            "receiverName": "XXXXXXXXXXXXX",
            "description": "You receive \$$amount",
            "amount": amount,
            "time": now
          });

          // Reset the form
          _usernameController.clear();
          _amountController.clear();

          setState(() {
            _isLoading = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Money sent successfully!')),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'User not found.';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Money'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Balance: \$$_balance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Receiver Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _sendMoney,
                    child: Text('Send Money'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
