import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/screens/home_screen.dart';
import 'package:date/screens/profile_editing_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/user_model.dart' as UserModel;
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>(
          create: (_) => UserData(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _userDataFromDb(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserData>(
      create: (_) => UserData(),
      child: MaterialApp(
        title: 'App',
        home: FutureBuilder<User?>(
          future: Future.value(_auth.currentUser),
          builder: (context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.hasData) {
              User? user = snapshot.data;
              if (user != null) {
                final userData = Provider.of<UserData>(context, listen: false);

                userData.setUser(UserModel.User(
                  uid: user.uid,
                  displayName: user.displayName!,
                  email: user.email!,
                  pictures: [user.photoURL!],
                ));

                return FutureBuilder<Map<String, dynamic>?>(
                  future: _userDataFromDb(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      userData.setUser(UserModel.User(
                        uid: user.uid,
                        displayName: snapshot.data!['displayName'] ?? '',
                        email: user.email!,
                        pictures: [user.photoURL!],
                        description: snapshot.data!['description'] ?? '',
                        interests: snapshot.data!['interests'] ?? {},
                        age: snapshot.data!['age'] ?? 0,
                      ));
                      if (snapshot.data!.keys.contains('description')) {
                        return HomePage();
                      } else {
                        return ProfileEditingScreen();
                      }
                    } else {
                      return Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                );
              } else {
                // User is not logged in, return the LoginScreen
                return LoginScreen();
              }
            } else {
              // User is not logged in, return the LoginScreen
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
