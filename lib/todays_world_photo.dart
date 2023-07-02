import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quon2/main_screen.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

import 'models/candidates_photo_model.dart';

class TodaysWorld extends StatefulWidget {
  const TodaysWorld({super.key});
  static const String id = 'todays_world';
  @override
  State<TodaysWorld> createState() => _TodaysWorldState();
}

class _TodaysWorldState extends State<TodaysWorld> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  final FirebaseAuth auth = FirebaseAuth.instance;
  MatchEngine? _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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

    for (int i = 0; i < photos.length; i++) {
      _swipeItems.add(SwipeItem(
          content: photos[i],
          likeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Liked ${photos[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          },
          nopeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Nope ${photos[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          },
          superlikeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Superliked ${photos[i]}"),
              duration: const Duration(milliseconds: 500),
            ));
          },
          onSlideUpdate: (SlideRegion? region) async {
            print("Region $region");
          }));
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
        future: _loadPhotos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Stack(children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: SwipeCards(
                  matchEngine: _matchEngine!,
                  itemBuilder: (BuildContext context, int index) {
                    return Image(
                        image: NetworkImage(_swipeItems[index].content));
                  },
                  onStackFinished: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Stack Finished"),
                      duration: Duration(milliseconds: 500),
                    ));
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        MainScreen.id, (route) => false);
                  },
                  itemChanged: (SwipeItem item, int index) {},
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
            ]);
          }
        },
      ),
    );
  }
}
