import 'package:date/screens/profile_editing_screen.dart';

class User {
  final int age;
  final String uid;
  final String email;
  final String displayName;
  final List<String> pictures;
  final String description;
  final Map<String, dynamic> interests;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.age = 0,
    this.pictures = const [],
    this.description = '',
    this.interests = const {
      'Chess': false,
      'Video games': false,
      'Hanging out': false,
      'Movies': false,
      'Parties': false,
      'Hiking': false
    },
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'age': age,
      'email': email,
      'displayName': displayName,
      'pictures': pictures,
      'description': description,
      'interests': interests,
    };
  }
}
