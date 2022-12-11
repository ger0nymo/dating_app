import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart' as UserModel;
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final result = await FirebaseAuth.instance.signInWithCredential(credential);

    final user = result.user;
    if (user != null) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .get();
      if (userSnapshot.docs.isEmpty) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': user.displayName!,
          'email': user.email!,
          'pictures': [user.photoURL!],
        });
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserData>(
      create: (_) => UserData(),
      child: Consumer<UserData>(
        builder: (context, userData, child) {
          return SafeArea(
            right: false,
            child: Scaffold(
              body: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo[400]!,
                      Colors.lightBlue[300]!,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'images/1.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          // 2. Show the header text
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              'Welcome to the app',
                              style: GoogleFonts.nunitoSans(
                                  fontSize: 28, color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(
                              'Please sign in to continue',
                              style: GoogleFonts.nunitoSans(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      // 3. Show the login button
                      SizedBox(
                        width: 200,
                        height: 55,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.person),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.indigo[600]),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            final result = await signInWithGoogle();
                            final user = result.user;
                            if (user != null) {
                              userData.setUser(UserModel.User(
                                uid: user.uid,
                                displayName: user.displayName!,
                                email: user.email!,
                                pictures: [user.photoURL!],
                              ));
                            }
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyApp(),
                              ),
                            );
                          },
                          label: Text('Sign in with Google',
                              style: GoogleFonts.nunitoSans()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
