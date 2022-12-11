import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class LikedScreen extends StatefulWidget {
  const LikedScreen({Key? key}) : super(key: key);

  @override
  State<LikedScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<String> matches = [];

  @override
  void initState() {
    super.initState();

    firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) {
      try {
        setState(() {
          matches = value.data()!['matches'].keys.toList();
        });
      } catch (e) {
        matches = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: firestore.collection('users').doc(matches[index]).get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> dataMap =
                    snapshot.data!.data()! as Map<String, dynamic>;
                return ListTile(
                  title: Text(dataMap['displayName']),
                  subtitle: Text(dataMap['age'].toString()),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(dataMap['pictures'][0]),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(partnerId: dataMap['uid'])));
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        },
      ),
    );
  }
}
