import 'package:flutter/material.dart';


class Store1 extends ChangeNotifier {
  var userName = '';
  var userEmail = '';

  saveUserData(name, email){
    userName = name;
    userEmail = email;
    notifyListeners();
  }
  saveUserEmail(email){
    userEmail = email;
    notifyListeners();
  }
}