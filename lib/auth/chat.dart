import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hiddenmenu/model/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
        final String userName = userData['name'] ?? 'Unknown User';
        return userName;
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print('Error getting user name: $e');
      return 'Unknown User';
    }
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  Future<void> sendMessage(
      String receiverID, String message, String mediaUrl) async {
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currenUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    String senderName = await getUserName(currentUserID); // Get sender's name

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currenUserEmail,
      senderName: senderName,
      receiverID: receiverID,
      message: message,
      media: mediaUrl,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Future<void> sendMediaMessage(
  //     String receiverID, String mediaDownloadURL) async {
  //   final String currentUserID = _firebaseAuth.currentUser!.uid;
  //   final String currenUserEmail = _firebaseAuth.currentUser!.email.toString();
  //   final Timestamp timestamp = Timestamp.now();

  //   String senderName = await getUserName(currentUserID);

  //   MediaMessage newMessage = MediaMessage(
  //     senderID: currentUserID,
  //     senderEmail: currenUserEmail,
  //     senderName: senderName,
  //     receiverID: receiverID,
  //     timestamp: timestamp,
  //     mediaURL: mediaDownloadURL,
  //   );

  //   List<String> ids = [currentUserID, receiverID];
  //   ids.sort();
  //   String chatRoomId = ids.join("_");

  //   await _firestore
  //       .collection('chat_rooms')
  //       .doc(chatRoomId)
  //       .collection('messagesMedia')
  //       .add(newMessage.toMap());
  // }

  // Stream<QuerySnapshot> getMediaMessages(String userID, String otherUserID) {
  //   List<String> ids = [userID, otherUserID];
  //   ids.sort();
  //   String chatRoomId = ids.join("_");

  //   return _firestore
  //       .collection('chat_rooms')
  //       .doc(chatRoomId)
  //       .collection('messagesMedia')
  //       .orderBy('timestamp', descending: false)
  //       .snapshots();
  // }
}
