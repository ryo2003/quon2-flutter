import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:quon2/login_view.dart';
import 'package:quon2/my_album.dart';
import 'package:quon2/world_album.dart';

enum MenuAction { logout, debug }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static String id = 'main_screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Track the current index of the selected screen
  String currentTitle = "My Album";
  final user = FirebaseAuth.instance.currentUser;

  final List<Widget> _screens = [
    const MyAlbum(), // The first screen
    const WorldAlbum(), // The second screen
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginView.id,
                      (_) => false,
                    );
                  }
                  break;
                case MenuAction.debug:
                  print(user);
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
                PopupMenuItem<MenuAction>(
                  value: MenuAction.debug,
                  child: Text('Test'),
                ),
              ];
            },
          )
        ],
      ),
      body: _screens[_currentIndex], // Display the current selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            _currentIndex, // Set the current index of the selected screen
        onTap: (int index) {
          setState(() {
            _currentIndex =
                index; // Update the current index when a screen is tapped
            currentTitle = _currentIndex == 0 ? "My Album" : "World Album";
            //myVar == null ? 0 : myVar ; If myVar is null then is 0, else then myVar
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'My Album',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: 'World Album',
          ),
        ],
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
