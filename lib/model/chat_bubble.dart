// import 'package:flutter/material.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;

//   const ChatBubble({
//     super.key,
//     required this.message,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
//           color: Colors.blue),
//       child: Text(
//         message,
//         style: const TextStyle(fontSize: 16, color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor, // Use the provided background color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: textColor, // Use the provided text color
        ),
      ),
    );
  }
}
