// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:flutter/material.dart';
// import 'package:hiddenmenu/auth/auth_services.dart';
// import 'package:hiddenmenu/component/my_button.dart';
// import 'package:hiddenmenu/component/my_text_field.dart';
// import 'package:provider/provider.dart';

// class MyRegisterPage extends StatefulWidget {
//   final void Function()? onTap;
//   const MyRegisterPage({super.key, required this.onTap});

//   @override
//   State<MyRegisterPage> createState() => _MyRegisterPageState();
// }

// class _MyRegisterPageState extends State<MyRegisterPage> {
//   Future<void> singUp() async {
//     if (passwordController.text != confirmPass.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Passwords do not match'),
//         ),
//       );
//     }

//     final authService = Provider.of<AuthService>(context, listen: false);
//     try {
//       await authService.signUpWithEmailandPassword(
//           emailController.text, passwordController.text);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             e.toString(),
//           ),
//         ),
//       );
//     }
//   }

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPass = TextEditingController();
//   final nameController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.cyan.shade50,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.message_rounded,
//                 size: 110,
//               ),
//               Text(
//                 "Let's Create an Account for You!",
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//               SizedBox(
//                 height: 40,
//               ),
//               MyTextField(
//                   controller: nameController,
//                   hintText: 'Name',
//                   obscureText: false),
//               SizedBox(
//                 height: 15,
//               ),
//               MyTextField(
//                   controller: emailController,
//                   hintText: 'Email',
//                   obscureText: false),
//               SizedBox(
//                 height: 15,
//               ),
//               MyTextField(
//                   controller: passwordController,
//                   hintText: 'Password',
//                   obscureText: true),
//               SizedBox(
//                 height: 15,
//               ),
//               MyTextField(
//                   controller: confirmPass,
//                   hintText: 'Confirm Password',
//                   obscureText: true),
//               SizedBox(
//                 height: 45,
//               ),
//               MyButton(
//                   onTap: () {
//                     singUp();
//                   },
//                   text: 'Sign Up'),
//               SizedBox(
//                 height: 45,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Already a member?'),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   GestureDetector(
//                     onTap: widget.onTap,
//                     child: Text(
//                       'Login Now!!!',
//                       style:
//                           TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
//                     ),
//                   )
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiddenmenu/auth/auth_services.dart';
import 'package:hiddenmenu/component/my_button.dart';
import 'package:hiddenmenu/component/my_text_field.dart';
import 'package:provider/provider.dart';

class MyRegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const MyRegisterPage({super.key, required this.onTap});

  @override
  State<MyRegisterPage> createState() => _MyRegisterPageState();
}

class _MyRegisterPageState extends State<MyRegisterPage> {
  Future<void> signUp() async {
    if (passwordController.text != confirmPass.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final UserCredential userCredential =
          await authService.signUpWithEmailandPassword(
              emailController.text, passwordController.text);

      final String uid = userCredential.user!.uid;

      // Store user information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text,
        'uid': uid,
        'email': emailController.text
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPass = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.message_rounded,
                size: 110,
              ),
              Text(
                "Let's Create an Account for You!",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              MyTextField(
                  controller: nameController,
                  hintText: 'Name',
                  obscureText: false),
              SizedBox(
                height: 15,
              ),
              MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false),
              SizedBox(
                height: 15,
              ),
              MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true),
              SizedBox(
                height: 15,
              ),
              MyTextField(
                  controller: confirmPass,
                  hintText: 'Confirm Password',
                  obscureText: true),
              SizedBox(
                height: 45,
              ),
              MyButton(
                  onTap: () {
                    signUp();
                  },
                  text: 'Sign Up'),
              SizedBox(
                height: 45,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already a member?'),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Login Now!!!',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
