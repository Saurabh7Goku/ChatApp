import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String senderName;
  final String receiverID;
  final String message;
  final String media;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.senderName,
    required this.receiverID,
    required this.message,
    required this.media,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderID,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'receiverId': receiverID,
      'message': message,
      'media': media,
      'timestamp': timestamp
    };
  }
}

// class MediaMessage {
//   final String senderID;
//   final String senderEmail;
//   final String senderName;
//   final String receiverID;
//   final String mediaURL;
//   final Timestamp timestamp;

//   MediaMessage({
//     required this.senderID,
//     required this.senderEmail,
//     required this.senderName,
//     required this.receiverID,
//     required this.mediaURL,
//     required this.timestamp,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'senderID': senderID,
//       'senderEmail': senderEmail,
//       'senderName': senderName,
//       'receiverID': receiverID,
//       'mediaURL': mediaURL,
//       'timestamp': timestamp,
//     };
//   }
// }
