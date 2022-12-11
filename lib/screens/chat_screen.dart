import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/main.dart';
import 'package:date/screens/profile_editing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import 'liked_screen.dart';

class ChatScreen extends StatefulWidget {
  String? partnerId;
  ChatScreen({Key? key, this.partnerId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 2;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List filtered = [];
  Map messages = {};

  TextEditingController messageController = TextEditingController();

  static const List<Widget> _widgetOptions = [
    HomeScreen(),
    ProfileEditingScreen(),
    LikedScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomePage(selectedIndex: index);
    }));
  }

  @override
  void initState() {
    super.initState();
    log('${widget.partnerId}');

    firestore
        .collection('chats')
        .where('users', arrayContains: auth.currentUser!.uid)
        .get()
        .then((value) {
      filtered = value.docs
          .where(
              (element) => element.data()['users'].contains(widget.partnerId))
          .toList();
      if (filtered.length > 0) {
        setState(() {
          messages = filtered[0].data()['messages']; //Filtered can be 1 only
        });
        log(messages.toString());
      } else {
        setState(() {
          messages = {};
        });
        firestore.collection('chats').add({
          'users': [auth.currentUser!.uid, widget.partnerId],
          'messages': {},
        });
      }
    });
    firestore
        .collection('chats')
        .where('users', arrayContains: auth.currentUser!.uid)
        .snapshots()
        .listen((event) {
      log('valami történt');
      filtered = event.docs
          .where(
              (element) => element.data()['users'].contains(widget.partnerId))
          .toList();
      if (filtered.isNotEmpty) {
        log('There are messages already');
        setState(() {
          messages = filtered[0].data()['messages'];
        });
      } else {
        setState(() {
          messages = {};
        });
        firestore.collection('chats').add({
          'users': [auth.currentUser!.uid, widget.partnerId],
          'messages': {},
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Matches'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  List keys = messages.keys.toList();
                  keys.sort();
                  return Container(
                    child: Row(
                      mainAxisAlignment: messages[keys[index]]['sender'] ==
                              auth.currentUser!.uid
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: messages[keys[index]]['sender'] ==
                                    auth.currentUser!.uid
                                ? Colors.indigo
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            messages[keys[index]]['message'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        firestore
                            .collection('chats')
                            .where('users',
                                arrayContains: auth.currentUser!.uid)
                            .get()
                            .then((value) {
                          filtered = value.docs
                              .where((element) => element
                                  .data()['users']
                                  .contains(widget.partnerId))
                              .toList();
                          if (filtered.length > 0) {
                            messages = filtered[0].data()['messages'];
                            messages[DateTime.now().toString()] = {
                              'sender': auth.currentUser!.uid,
                              'message': messageController.text
                            };
                            firestore
                                .collection('chats')
                                .doc(filtered[0].id)
                                .update({'messages': messages});
                            messageController.clear();
                          } else {
                            messages = {};
                            firestore.collection('chats').add({
                              'users': [
                                auth.currentUser!.uid,
                                widget.partnerId
                              ],
                              'messages': {
                                DateTime.now().toString(): {
                                  'sender': auth.currentUser!.uid,
                                  'message': messageController.text
                                }
                              },
                            });
                          }
                          messageController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
