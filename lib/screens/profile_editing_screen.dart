import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/main.dart';
import 'package:date/models/user_model.dart' as UserModel;
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

enum UploadState { uploading, done, stopped }

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({Key? key}) : super(key: key);
  @override
  State<ProfileEditingScreen> createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  final _formKey = GlobalKey<FormState>();

  late File _profilePicture;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  UploadState _uploadState = UploadState.stopped;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfilePicture(String uid) async {
    final pickedImage = await _picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profilePicture = File(pickedImage.path);
      });
      final storageRef = FirebaseStorage.instance.ref();

      final uploadTask = storageRef
          .child("users/$uid/profilePicture")
          .putFile(File(pickedImage.path));

      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
        switch (taskSnapshot.state) {
          case TaskState.running:
            _uploadState = UploadState.uploading;
            final progress = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            print("Upload is $progress% complete.");
            break;
          case TaskState.paused:
            print("Upload is paused.");
            break;
          case TaskState.canceled:
            setState(() {
              _uploadState = UploadState.stopped;
            });
            print("Upload was canceled");
            break;
          case TaskState.error:
            setState(() {
              _uploadState = UploadState.stopped;
            });
            break;
          case TaskState.success:
            setState(() {
              _uploadState = UploadState.done;
            });
            final downloadUrl = await storageRef
                .child("users/$uid/profilePicture")
                .getDownloadURL();
            FirebaseFirestore.instance.collection('users').doc(uid).update({
              'pictures': [downloadUrl]
            });
            break;
        }
      });
    }
  }

  bool hasRendered = false;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    if (!hasRendered) {
      _nameController.text = userData.user.displayName;
      _ageController.text = userData.user.age.toString();
      _descriptionController.text = userData.user.description;
      setState(() {
        hasRendered = true;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Edit Profile',
                  style:
                      GoogleFonts.nunitoSans(fontSize: 28, color: Colors.black),
                ),
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Use your real name. Or a nickname. Whatever you want.',
                              style: GoogleFonts.nunitoSans(
                                  color: Colors.black, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            textDirection: TextDirection.ltr,
                            controller: _nameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                            style: GoogleFonts.nunitoSans(color: Colors.black),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: GoogleFonts.nunitoSans(
                                  color: Colors.black, fontSize: 16),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[700]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            width: 350,
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an age';
                                }
                                return null;
                              },
                              style:
                                  GoogleFonts.nunitoSans(color: Colors.black),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelText: 'Age',
                                labelStyle: GoogleFonts.nunitoSans(
                                    color: Colors.black, fontSize: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[700]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            width: 350,
                            child: TextFormField(
                              controller: _descriptionController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                              style:
                                  GoogleFonts.nunitoSans(color: Colors.black),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: GoogleFonts.nunitoSans(
                                    color: Colors.black, fontSize: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[700]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.indigo[600],
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                              icon: Icon(Icons.photo),
                              onPressed: () {
                                _pickProfilePicture(userData.user.uid);
                              },
                              label: _uploadState == UploadState.done
                                  ? Text('Select a new profile picture')
                                  : Text('Add a profile picture')),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.indigo[600],
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  ),
                                  icon: Icon(Icons.add),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      userData.setUser(UserModel.User(
                                        uid: userData.user.uid,
                                        displayName: _nameController.text,
                                        email: userData.user.email,
                                        age: int.parse(_ageController.text),
                                        description:
                                            _descriptionController.text,
                                        pictures: userData.user.pictures,
                                      ));

                                      final userRef = FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userData.user.uid);
                                      await userRef.update({
                                        'displayName': _nameController.text,
                                        'age':
                                            int.tryParse(_ageController.text),
                                        'description':
                                            _descriptionController.text,
                                      });

                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text('Interests',
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            color:
                                                                Colors.black)),
                                                content: Interests(
                                                    user: userData.user),
                                              ));
                                    }
                                  },
                                  label: const Text('Add interests'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.grey[600],
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  userData.setUser(UserModel.User(
                                    uid: userData.user.uid,
                                    displayName: _nameController.text.isNotEmpty
                                        ? _nameController.text
                                        : userData.user.displayName,
                                    email: userData.user.email,
                                    age: _ageController.text != '0'
                                        ? int.tryParse(_ageController.text) ??
                                            userData.user.age
                                        : userData.user.age,
                                    description:
                                        _descriptionController.text != ''
                                            ? _descriptionController.text
                                            : userData.user.description,
                                    pictures: userData.user.pictures,
                                  ));

                                  final userRef = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userData.user.uid);
                                  await userRef.update({
                                    'displayName':
                                        _nameController.text.isNotEmpty
                                            ? _nameController.text
                                            : userData.user.displayName,
                                    'age': _ageController.text != '0'
                                        ? int.tryParse(_ageController.text)
                                        : userData.user.age,
                                    'description':
                                        _descriptionController.text != ''
                                            ? _descriptionController.text
                                            : userData.user.description,
                                  });
                                }
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyApp()));
                              },
                              child: Text(
                                'Finish editing',
                                style:
                                    GoogleFonts.nunitoSans(color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Interests extends StatefulWidget {
  final UserModel.User user;
  Interests({Key? key, required this.user}) : super(key: key);

  @override
  State<Interests> createState() => InterestsState();
}

class InterestsState extends State<Interests> {
  final Map<String, bool> _options = {
    'Chess': false,
    'Video games': false,
    'Hanging out': false,
    'Movies': false,
    'Parties': false,
    'Hiking': false
  };
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Column(
        children: [
          StaggeredGrid.count(
            crossAxisCount: 4,
            children: [
              for (var entry in _options.entries)
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          _options[entry.key]!
                              ? Colors.indigo[500]
                              : Colors.grey[100],
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      child: Text(
                        entry.key.toString(),
                        style: GoogleFonts.nunitoSans(
                            color: _options[entry.key]!
                                ? Colors.white
                                : Colors.black),
                      ),
                      onPressed: () async {
                        setState(() {
                          _options[entry.key] = !_options[entry.key]!;
                        });
                        final userRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.user.uid);
                        userRef.update({'interests': _options});
                      },
                    ),
                  ),
                )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ElevatedButton.icon(
                icon: Icon(Icons.check),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.indigo[500]),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                label: Text(
                  'Done',
                  style: GoogleFonts.nunitoSans(),
                )),
          )
        ],
      ),
    );
  }
}
