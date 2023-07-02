import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quon2/main_screen.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

import 'models/candidates_photo_model.dart';

class TodaysWorld extends StatefulWidget {
  const TodaysWorld({super.key});

  @override
  State<TodaysWorld> createState() => _TodaysWorldState();
}

class _TodaysWorldState extends State<TodaysWorld> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  final FirebaseAuth auth = FirebaseAuth.instance;

  MatchEngine? _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final List<String> _names = [
    "Red",
    "Blue",
    "Green",
    "Yellow",
    "Orange",
    "Grey",
    "Purple",
    "Pink"
  ];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.grey,
    Colors.purple,
    Colors.pink
  ];

  List<String> _photosUrl = [];

  Future<void> _loadPhotos() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('candidate_photos')
        .where("uploaderUid", isEqualTo: uid)
        .get();
    Map<String, dynamic> data;
    List<String> photos = [];
    for (var doc in snapshot.docs) {
      data = doc.data() as Map<String, dynamic>;
      photos.add(data['imageUrl']);
    }
    setState(() {
      _photosUrl = photos;
      //print(_photosUrl);
    });
    for (int i = 0; i < _photosUrl.length; i++) {
      _swipeItems.add(SwipeItem(
          content: _photosUrl[i],
          likeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Liked ${_photosUrl[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          },
          nopeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Nope ${_photosUrl[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          },
          superlikeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Superliked ${_photosUrl[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          },
          onSlideUpdate: (SlideRegion? region) async {
            print("Region $region");
          }));
    }
    //print(_swipeItems[0].content);
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  @override
  void initState() {
    _loadPhotos();
    //print(_photosUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight,
            child: SwipeCards(
              matchEngine: _matchEngine!,
              itemBuilder: (BuildContext context, int index) {
                return Image(image: NetworkImage(_photosUrl[index]));
              },
              onStackFinished: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Stack Finished"),
                  duration: Duration(milliseconds: 500),
                ));
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(MainScreen.id, (route) => false);
              },
              itemChanged: (SwipeItem item, int index) {
                //print("item: ${item.content.text}, index: $index");
              },
              leftSwipeAllowed: true,
              rightSwipeAllowed: true,
              upSwipeAllowed: true,
              fillSpace: true,
              likeTag: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.green)),
                child: Text('Like'),
              ),
              nopeTag: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.red)),
                child: Text('Nope'),
              ),
              superLikeTag: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.orange)),
                child: Text('Super Like'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      _matchEngine!.currentItem?.nope();
                    },
                    child: Text("Nope")),
                ElevatedButton(
                    onPressed: () {
                      _matchEngine!.currentItem?.superLike();
                    },
                    child: Text("Superlike")),
                ElevatedButton(
                    onPressed: () {
                      _matchEngine!.currentItem?.like();
                    },
                    child: Text("Like"))
              ],
            ),
          )
        ]));
  }
}
