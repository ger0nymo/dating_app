import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart' as UserModel;

class UserData with ChangeNotifier {
  late UserModel.User _user;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserData() {
    _user = UserModel.User(
      uid: '',
      displayName: '',
      email: '',
      description: '',
      interests: {},
      pictures: [],
    );
  }

  UserModel.User get user => _user;

  setUser(UserModel.User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> saveUser(String name, int age, Map<String, dynamic> interests,
      String picture) async {
    _user = UserModel.User(
      uid: _user.uid,
      displayName: name,
      email: _user.email,
      description: _user.description,
      interests: interests,
      pictures: picture != null ? [..._user.pictures, picture] : _user.pictures,
    );
    notifyListeners();

    await _db
        .collection('users')
        .doc(_user.uid)
        .set(_user.toMap(), SetOptions(merge: true));
  }
}
