// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hiddenmenu/auth/chat.dart';
import 'package:hiddenmenu/component/my_text_field.dart';
import 'package:hiddenmenu/model/chat_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receivername;
  const ChatPage({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receivername,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  String formattedReceiverName = '';
  AppLifecycleState appState = AppLifecycleState.resumed;
  String lastSeen = '';
  bool isReceiverOnline = false;
  String mediaDownloadURL = '';

  @override
  void initState() {
    super.initState();
    formattedReceiverName = _formatName(widget.receivername);
    WidgetsBinding.instance.addObserver(this);
    _updateUserStatus(true);
    _getLastSeen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateUserStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      appState = state;
    });

    if (appState == AppLifecycleState.paused) {
      _updateUserStatus(false);
    } else if (appState == AppLifecycleState.resumed) {
      _updateUserStatus(true);
    }
  }

  String _formatName(String name) {
    if (name.isEmpty) {
      return name;
    }
    return '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
  }

  void _updateUserStatus(bool isOnline) {
    if (_firebaseAuth.currentUser != null) {
      final userPresenceRef =
          FirebaseFirestore.instance.collection('user_presence');
      final userDoc = userPresenceRef.doc(_firebaseAuth.currentUser!.uid);

      if (isOnline) {
        userDoc.set({
          'isOnline': true,
          'lastSeen': null,
        });
      } else {
        userDoc.update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  void _getLastSeen() {
    final userPresenceRef =
        FirebaseFirestore.instance.collection('user_presence');
    final userDoc = userPresenceRef.doc(widget.receiverUserID);

    userDoc.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final isOnline = data['isOnline'];

        if (isOnline) {
          setState(() {
            lastSeen = 'Online';
            isReceiverOnline = true;
          });
        } else {
          final lastSeenTime = data['lastSeen'] as Timestamp?;
          if (lastSeenTime != null) {
            final formatter = DateFormat('d MMM HH:mm');
            final lastSeenDateTime = lastSeenTime.toDate();
            setState(() {
              lastSeen = 'Last Seen: ${formatter.format(lastSeenDateTime)}';
              isReceiverOnline = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade200,
      appBar: AppBar(
        title: Row(
          children: [
            Text(formattedReceiverName),
            SizedBox(width: 8),
            _buildStatusDot(),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                lastSeen,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Widget _buildMessageList() {
  //   return StreamBuilder(
  //     stream: _chatService.getMessages(
  //       widget.receiverUserID,
  //       _firebaseAuth.currentUser!.uid,
  //     ),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return Text('Error${snapshot.error}');
  //       }
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Text('Loading...');
  //       }

  //       return ListView(
  //         children: snapshot.data!.docs
  //             .map((document) => _buildMessageItem(document))
  //             .toList(),
  //       );
  //     },
  //   );
  // }
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserID,
        _firebaseAuth.currentUser!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // Calculate the total height based on message lengths
        double totalHeight = 0.0;
        for (var document in snapshot.data!.docs) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String message = data['message'].toString();
          totalHeight += message.length * 10.0; // Adjust this factor as needed
        }

        // Scroll to the calculated total height
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _scrollController.jumpTo(totalHeight);
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // Widget _buildMessageItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data() as Map<String, dynamic>;

  //   var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //       ? Alignment.centerRight
  //       : Alignment.centerLeft;

  //   // Check if the message starts with 'https://firebasestorage.googleapis.com'
  //   if (data['message'].startsWith(
  //       'https://firebasestorage.googleapis.com/v0/b/chatapp-e689f.appspot.com')) {
  //     return Container(
  //       alignment: alignment,
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           crossAxisAlignment:
  //               (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //                   ? CrossAxisAlignment.end
  //                   : CrossAxisAlignment.start,
  //           mainAxisAlignment:
  //               (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //                   ? MainAxisAlignment.end
  //                   : MainAxisAlignment.start,
  //           children: [
  //             Text(data['senderName'].toString().toUpperCase()),
  //             Image.network(
  //               data['message'],
  //             ),
  //             Text(
  //               _formatTimestamp(data['timestamp']),
  //               style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
  //             )
  //           ],
  //         ),
  //       ),
  //     );
  //   } else {
  //     // Regular text message
  //     return Container(
  //       alignment: alignment,
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           crossAxisAlignment:
  //               (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //                   ? CrossAxisAlignment.end
  //                   : CrossAxisAlignment.start,
  //           mainAxisAlignment:
  //               (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //                   ? MainAxisAlignment.end
  //                   : MainAxisAlignment.start,
  //           children: [
  //             Text(data['senderName'].toString().toUpperCase()),
  //             ChatBubble(
  //               message: data['message'],
  //               backgroundColor:
  //                   data['senderId'] == _firebaseAuth.currentUser!.uid
  //                       ? Colors.blue
  //                       : Colors.green,
  //               textColor: Colors.white, // Customize text color
  //             ),
  //             Text(_formatTimestamp(data['timestamp']),
  //                 style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    // Check if the message starts with 'https://firebasestorage.googleapis.com'
    if (data['message'].startsWith(
        'https://firebasestorage.googleapis.com/v0/b/chatapp-e689f.appspot.com')) {
      return GestureDetector(
        onLongPress: () {
          // Show a context menu for deleting the message
          showDeleteMessageContextMenu(document.id);
        },
        child: Container(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid)
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              mainAxisAlignment:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              children: [
                Text(data['senderName'].toString().toUpperCase()),
                Image.network(
                  data['message'],
                ),
                Text(
                  _formatTimestamp(data['timestamp']),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      // Regular text message
      return GestureDetector(
        onLongPress: () {
          // Show a context menu for deleting the message
          showDeleteMessageContextMenu(document.id);
        },
        child: Container(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid)
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              mainAxisAlignment:
                  (data['senderId'] == _firebaseAuth.currentUser!.uid)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              children: [
                Text(data['senderName'].toString().toUpperCase()),
                ChatBubble(
                  message: data['message'],
                  backgroundColor:
                      data['senderId'] == _firebaseAuth.currentUser!.uid
                          ? Colors.blue
                          : Colors.green,
                  textColor: Colors.white, // Customize text color
                ),
                Text(_formatTimestamp(data['timestamp']),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      );
    }
  }

  String getChatRoomId(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    return ids.join("_");
  }

  void showDeleteMessageContextMenu(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Message?'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                // Delete the message from the database
                final chatRoomId = getChatRoomId(
                    widget.receiverUserID, _firebaseAuth.currentUser!.uid);
                _chatService.deleteMessage(chatRoomId, messageId);

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Enter Message',
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: () {
              _pickAndUploadImage();
            },
            icon: Icon(
              Icons.file_upload_outlined,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.send_rounded,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // void pickAndUploadMedia() async {
  //   FilePickerResult? result =
  //       await FilePicker.platform.pickFiles(type: FileType.media);

  //   if (result != null && result.files.isNotEmpty) {
  //     String filePath = result.files.single.path!;
  //     Reference storageRef =
  //         FirebaseStorage.instance.ref().child('media/${DateTime.now()}');
  //     UploadTask uploadTask = storageRef.putFile(File(filePath));

  //     TaskSnapshot snapshot = await uploadTask;
  //     mediaDownloadURL = await snapshot.ref.getDownloadURL();
  //     setState(() {});
  //   }
  // }

  Future<void> _pickAndUploadImage() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // final androidInfo = await DeviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        final storagePermission = await Permission.storage.request();
        if (storagePermission.isGranted) {
          print('permission granted');
          _handleImageSelection();
        } else {
          print('permission Denied');
        }
      } else {
        final photosPermission = await Permission.photos.request();
        if (photosPermission.isGranted) {
          print('permission photo granted');
          _handleImageSelection();
        } else {
          print('permission photo Denied');
        }
      }
    } else {}
  }

  void sendMessageWithImage(String downloadURL) async {
    if (downloadURL.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, downloadURL, '');

      mediaDownloadURL = '';
    }
  }

  void _handleImageSelection() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      String imageName = Path.basename(image.path);

      Reference storageReference =
          FirebaseStorage.instance.ref().child(imageName);

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

          sendMessageWithImage(mediaDownloadURL);
        } catch (e) {
          print('Error uploading image: $e');
        }
      });
    } else {
      // No image selected.
    }
  }

  Widget _buildStatusDot() {
    Color dotColor = isReceiverOnline ? Colors.green : Colors.red;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
      ),
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text, mediaDownloadURL);

      _messageController.clear();
      mediaDownloadURL = '';
    }
  }

  // void sendMediaMessage() async {
  //   if (mediaDownloadURL.isNotEmpty) {
  //     await _chatService.sendMediaMessage(
  //       widget.receiverUserID,
  //       mediaDownloadURL,
  //     );
  //     mediaDownloadURL = '';
  //   }
  // }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    final formatter = DateFormat('d MMM HH:mm');
    String formattedDate = formatter.format(dateTime);

    return formattedDate;
  }
}
