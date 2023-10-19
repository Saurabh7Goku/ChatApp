import 'package:flutter/material.dart';
import 'package:hiddenmenu/auth/auth_services.dart';

class LogoutButton extends StatelessWidget {
  final BuildContext context;

  LogoutButton(this.context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Log Out"),
              onPressed: () {
                logout();
                // Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  void logout() {
    final authService =
        AuthService(); // Initialize or get your AuthService instance
    authService
        .signOut(); // Call the signOut method provided by your AuthService
    // You may also add code to navigate to the login screen or clear user data, depending on your app's requirements.
  }
}
