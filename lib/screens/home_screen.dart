import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/models/user_model.dart' as UserModel;
import 'package:date/screens/liked_screen.dart';
import 'package:date/screens/login_screen.dart';
import 'package:date/screens/profile_editing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  int? selectedIndex;

  HomePage({this.selectedIndex});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex ?? 0;
  }

  static const List<Widget> _widgetOptions = [
    HomeScreen(),
    ProfileEditingScreen(),
    LikedScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Text(
                'Dating app',
                style: GoogleFonts.nunitoSans(
                  color: Colors.black,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return LoginScreen();
                  }));
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
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
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List users = [];
  late List swipesOfUser = [];

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((document) {
      setState(() {
        swipesOfUser = document.get('swipes').keys.toList();
      });
      log('Swipes of user: ${swipesOfUser.length}');

      FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((document) {
          if (!swipesOfUser.contains(document.data()['uid'])) {
            setState(() {
              users.add(document);
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: users.isNotEmpty
            ? users
                .map((user) => SwipeableCard(
                      user: user,
                      remove: () {
                        log('Old users list: ${users.length}');
                        setState(() {
                          log("Removing ${user!['displayName']} from users");
                          users.remove(user);
                        });

                        log('New users list: ${users.length}');
                      },
                    ))
                .toList()
            : [
                Center(
                    child: Text('No more users to show :(',
                        style: GoogleFonts.nunitoSans(fontSize: 20)))
              ],
      ),
    );
  }
}

class SwipeableCard extends StatefulWidget {
  final DocumentSnapshot? user;

  final Function remove;

  const SwipeableCard({
    Key? key,
    this.user,
    required this.remove,
  }) : super(key: key);

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> {
  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: 'Card data',
      feedback: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18)),
                      child: Image.network(widget.user!['pictures'][0],
                          fit: BoxFit.cover),
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                        '${widget.user!['displayName']}, ${widget.user!['age']}',
                        style: GoogleFonts.nunitoSans(
                            fontSize: 20, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.start),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Likes ${widget.user!['interests'].keys.toList().where((element) {
                              return widget.user!['interests'][element] == true;
                            }).join(', ')}',
                            style: GoogleFonts.nunitoSans(
                                fontStyle: FontStyle.italic)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Bio: ${widget.user!['description']}',
                            style: GoogleFonts.nunitoSans()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Container(),
      onDraggableCanceled: (Velocity velocity, Offset offset) async {
        final screenWidth = MediaQuery.of(context).size.width;

        Map<String, bool> swipes = {};

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          try {
            value.data()!['swipes'].forEach((key, value) {
              swipes[key] = value;
            });
          } catch (e) {
            log('message: ${e.toString()}');
            swipes = {};
          }
          swipes[widget.user!['uid']] = false;
        });

        if (offset.dx <= -0.1) {
          swipes[widget.user!['uid']] = false;
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'swipes': swipes});
        } else if (offset.dx > 0.1) {
          swipes[widget.user!['uid']] = true;
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'swipes': swipes});

          bool match = false;
          try {
            match = widget.user!['swipes']
                    [FirebaseAuth.instance.currentUser!.uid] ==
                true;
          } catch (e) {
            log('message: $e');
            match = false;
          }

          if (match) {
            Map<String, bool> anotherUserMatches = {};
            try {
              widget.user!['matches'].forEach((key, value) {
                anotherUserMatches[key] = value;
              });
            } catch (e) {
              anotherUserMatches = {};
            }

            anotherUserMatches[FirebaseAuth.instance.currentUser!.uid] = true;

            FirebaseFirestore.instance
                .collection('users')
                .doc(widget.user!['uid'])
                .update({'matches': anotherUserMatches});

            Map<String, bool> currentUserMatches = {};
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get()
                .then((value) {
              try {
                value.data()!['matches'].forEach((key, value) {
                  currentUserMatches[key] = value;
                });
              } catch (e) {
                currentUserMatches = {};
              }
              currentUserMatches[widget.user!['uid']] = true;

              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({'matches': currentUserMatches});
            });
          }
        }
        widget.remove();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.55,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18)),
                  child: Image.network(
                    widget.user!['pictures'][0],
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                      '${widget.user!['displayName']}, ${widget.user!['age']}',
                      style: GoogleFonts.nunitoSans(
                          fontSize: 20, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.start),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Likes ${widget.user!['interests'].keys.toList().where((element) {
                            return widget.user!['interests'][element] == true;
                          }).join(', ')}',
                          style: GoogleFonts.nunitoSans(
                              fontStyle: FontStyle.italic)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Bio: ${widget.user!['description']}',
                          style: GoogleFonts.nunitoSans()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
