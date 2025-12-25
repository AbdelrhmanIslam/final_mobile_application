import 'package:flutter/material.dart';

// Simple Models
class UserAddress {
  final String name;
  final String city;
  final String address;
  final String phone;

  UserAddress(this.name, this.city, this.address, this.phone);
}

class UserCard {
  final String owner;
  final String number;
  final String exp;
  final String cvv;
  final int type; // 0=Master, 1=Paypal, 2=Bank (mapped to icons)

  UserCard(this.owner, this.number, this.exp, this.cvv, this.type);
}

class UserDataProvider with ChangeNotifier {
  // 1. ADDRESS STATE
  UserAddress? _currentAddress;
  UserAddress? get currentAddress => _currentAddress;

  void saveAddress(String name, String city, String address, String phone) {
    _currentAddress = UserAddress(name, city, address, phone);
    notifyListeners();
  }

  // 2. CARDS STATE
  List<UserCard> _savedCards = [];
  UserCard? _selectedCard;

  List<UserCard> get savedCards => _savedCards;
  UserCard? get selectedCard => _selectedCard;

  void addCard(String owner, String number, String exp, String cvv, int type) {
    final newCard = UserCard(owner, number, exp, cvv, type);
    _savedCards.add(newCard);
    // If it's the first card, auto-select it
    if (_savedCards.length == 1) {
      _selectedCard = newCard;
    }
    notifyListeners();
  }

  void selectPaymentMethod(UserCard card) {
    _selectedCard = card;
    notifyListeners();
  }
}