import 'package:flutter/material.dart';

import '../constant/ThemeColor.dart';

class CardModel {
  String cardHolderName;
  String cardNumber;
  String expDate;
  String cvv;
  Color cardColor;

  CardModel({
    required this.cardHolderName,
    required this.cardNumber,
    required this.cvv,
    required this.expDate,
    required this.cardColor,
  });
}

List<CardModel> myCards = [
  CardModel(
    cardHolderName: "Your Piggy Card",
    cardNumber: "****  ****  ****  1234",
    cvv: "**4",
    expDate: "12/21",
    cardColor: kPrimaryColor,
  ),
  CardModel(
    cardHolderName: "Your Credit/Debit",
    cardNumber: "****  ****  ****  4321",
    cvv: "**1",
    expDate: "01/22",
    cardColor: kSecondaryColor,
  ),
];