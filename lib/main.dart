import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quon2/login_view.dart';
import 'package:quon2/main_screen.dart';
import 'package:quon2/my_album.dart';
import 'package:quon2/register_view.dart';
import 'package:quon2/todays_world_photo.dart';
import 'package:quon2/verify_email_view.dart';
import 'package:cron/cron.dart';

import 'firebase_options.dart';
import 'models/selected_photos.dart';

Future<String> fetchSelectedPhoto() async {
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('candidate_photos')
      .where("storedDate",
          isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
      .get();
  Map<String, dynamic> data;
  String photo = "";
  int currentLikes = 0;
  for (var doc in snapshot.docs) {
    data = doc.data() as Map<String, dynamic>;
    if (data['numOfLikes'] > currentLikes) {
      currentLikes = data['numOfLikes'];
      photo = data['imageUrl'];
    }
  }
  return photo;
}

Future<void> _uploadPhoto() async {
  final downloadUrl = await fetchSelectedPhoto();

  // Save photo data to Firestore

  final photo = SelectedPhoto(
    id: "",
    createdAt: Timestamp.now(),
    uploaderUid:
        FirebaseAuth.instance.currentUser!.uid, //TODO: needs to be fixed
    imageUrl: downloadUrl,
    storedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  await FirebaseFirestore.instance
      .collection('selected_photos')
      .add(photo.toMap());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var cron = Cron();
  cron.schedule(Schedule.parse('* 1 * * *'), () async {
    //this code runs everyday at 1:00am
    _uploadPhoto();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My 1 Second App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        MyAlbum.id: (context) => const MyAlbum(),
        MainScreen.id: (context) => const MainScreen(),
        RegisterView.id: (context) => const RegisterView(),
        LoginView.id: (context) => const LoginView(),
        TodaysWorld.id: (context) => const TodaysWorld(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                print("email is verified");
              } else {
                print("not verified");
                //return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
            return const TodaysWorld();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
