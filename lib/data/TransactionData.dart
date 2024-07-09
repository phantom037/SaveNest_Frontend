import 'package:flutter/material.dart';

class TransactionModel {
  String name;
  String avatar;
  double amount;
  Color color;

  TransactionModel({
    required this.name,
    required this.avatar,
    required this.amount,
    required this.color,
  });
}

List<TransactionModel> myTransactions = [
  TransactionModel(
    avatar: "https://i.pinimg.com/736x/eb/a6/37/eba6371844d5e9f4e0b5b4a14e0ca7d6.jpg",
    name: "Supreme Leader",
    amount: 1200.65,
    color: Colors.red,
  ),
  TransactionModel(
    avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdIyWM-O6muANK8OXF6Rlqfa2UN39uIkNB9JA53u8l9V_I3z42yuEjDhuuT4Co9MQRL9M&usqp=CAU",
    name: "Your birthdate",
    amount: 79.14,
    color: Colors.green,
  ),
  TransactionModel(
    avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRi75pagnYGzVy6h46hROBi0EXmF0QcDLPNlR4dXuxKWoKf3b82b2wERoukPo4PRFq5z5o&usqp=CAU",
    name: "Group splitting",
    amount: 35.81,
    color: Colors.red,
  ),
  TransactionModel(
    avatar: "https://fortunetown.co.th/wp-content/uploads/2021/10/Mudonald.jpg",
    name: "Mc Donald's",
    amount: 12.85,
    color: Colors.red,
  ),
  TransactionModel(
    avatar: "https://img.freepik.com/free-psd/3d-illustration-human-avatar-profile_23-2150671159.jpg",
    name: "Alex Doe",
    amount: 120,
    color: Colors.green!,
  ),
  TransactionModel(
    avatar: "https://marketplace.canva.com/EAFUE8-O5cg/1/0/1600w/canva-blue-simple-mineral-water-logo-YOIBvEi14TQ.jpg",
    name: "Water Bill",
    amount: 137.72,
    color: Colors.red,
  ),
];