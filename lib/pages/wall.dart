import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

class SocialMediaWall extends StatefulWidget {
  @override
  _SocialMediaWallState createState() => _SocialMediaWallState();
}

class _SocialMediaWallState extends State<SocialMediaWall> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String mediaDownloadURL = '';

  late String userId; // Current user's ID

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  // Initialize the user
  void _initUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  void uploadMedia() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      String imageName = Path.basename(image.path);

      // Set the storage reference path to include the "wall" folder
      Reference storageReference =
          FirebaseStorage.instance.ref().child('wall/$imageName');

      UploadTask uploadTask = storageReference.putFile(image);

      uploadTask.whenComplete(() async {
        try {
          // Image uploaded successfully
          print('Image uploaded.');
          String downloadURL = await storageReference.getDownloadURL();
          print('Download URL: $downloadURL');

          setState(() {
            mediaDownloadURL = downloadURL;
          });
          _saveMediaUrl(mediaDownloadURL);
        } catch (e) {
          print('Error uploading image: $e');
        }
      });
    } else {
      // No image selected.
    }
  }

  // Function to save media URL to Firestore
  Future<void> _saveMediaUrl(String mediaUrl) async {
    await _firestore.collection('media').add({
      'userId': userId,
      'mediaUrl': mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Function to delete media
  Future<void> _deleteMedia(String mediaId) async {
    await _firestore.collection('media').doc(mediaId).delete();
    // You may want to also delete the media from Firebase Storage here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('media').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final mediaList = snapshot.data?.docs ?? [];

                  return Column(
                    children: mediaList.map((mediaDoc) {
                      final mediaData = mediaDoc.data() as Map<String, dynamic>;
                      final mediaUrl = mediaData['mediaUrl'].toString();
                      final userId = mediaData['userId'].toString();

                      return StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('users')
                            .doc(userId)
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          final userData =
                              userSnapshot.data?.data() as Map<String, dynamic>;
                          final userName = userData['name'].toString();

                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Center(
                                    child: Text(
                                      userName.toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ),
                                ),
                                Image.network(mediaUrl),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteMedia(mediaDoc.id);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          uploadMedia();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
