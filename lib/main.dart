// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:hiddenmenu/auth/auth_gate.dart';
import 'package:hiddenmenu/auth/auth_services.dart';
import 'package:hiddenmenu/firebase_options.dart';
import 'package:hiddenmenu/pages/homepage.dart';
import 'package:hiddenmenu/pages/logout.dart';
import 'package:hiddenmenu/pages/overview.dart';
import 'package:hiddenmenu/pages/wall.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class HiddenSideBarMenu extends StatefulWidget {
  const HiddenSideBarMenu({super.key});

  @override
  State<HiddenSideBarMenu> createState() => _HiddenSideBarMenuState();
}

class _HiddenSideBarMenuState extends State<HiddenSideBarMenu> {
  List<ScreenHiddenDrawer> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(
      ScreenHiddenDrawer(
        ItemHiddenMenu(
            name: "Home",
            baseStyle:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 22.0),
            colorLineSelected: Colors.deepOrangeAccent,
            selectedStyle: TextStyle(color: Colors.white, fontSize: 28.0)),
        Homepage(),
      ),
    );
    _pages.add(
      ScreenHiddenDrawer(
        ItemHiddenMenu(
            name: "Social Wall",
            baseStyle:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 22.0),
            colorLineSelected: Colors.deepOrangeAccent,
            selectedStyle: TextStyle(color: Colors.white, fontSize: 28.0)),
        SocialMediaWall(),
      ),
    );
    _pages.add(
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Setting",
          baseStyle:
              TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 22.0),
          colorLineSelected: Colors.deepOrangeAccent,
          selectedStyle: TextStyle(color: Colors.white, fontSize: 28.0),
          // icon: Icon(Icons.home), // Add the home icon
        ),
        SocialMediaWall(),
      ),
    );
    _pages.add(
      ScreenHiddenDrawer(
        ItemHiddenMenu(
            name: "Log Out",
            baseStyle:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 22.0),
            colorLineSelected: Colors.deepOrangeAccent,
            selectedStyle: TextStyle(color: Colors.white, fontSize: 28.0)),
        LogoutButton(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      backgroundColorMenu: Colors.blue.shade300,
      screens: _pages,
      initPositionSelected: 0,
      slidePercent: 65,
    );
  }
}
