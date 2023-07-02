import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:quon2/add_photo.dart';

class WorldAlbum extends StatefulWidget {
  const WorldAlbum({Key? key}) : super(key: key);
  static const String id = 'my_album';
  static const String title = 'My Album';

  @override
  State<WorldAlbum> createState() => _WorldAlbumState();
}

class _WorldAlbumState extends State<WorldAlbum> {
  static const int numDatesPerLoad =
      30; // Number of dates to generate in one batch
  List<DateTime> calendarDates = [];
  int currentPageIndex = 0;
  Map<String, String>? datesToUrl = {};

  @override
  void initState() {
    super.initState();
    generateCalendarDates(currentPageIndex);
    fetchPhoto();
  }

  Future<void> fetchPhoto() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('photos')
          .where("isWorld", isEqualTo: true)
          .get();

      Map<String, dynamic> data;

      for (var doc in snapshot.docs) {
        data = doc.data() as Map<String, dynamic>;
        datesToUrl?[data["storedDate"]] = data['imageUrl'];
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching photos: $e');
    }
  }

  void generateCalendarDates(int startIndex) {
    DateTime now = DateTime.now();

    for (int i = startIndex; i < startIndex + numDatesPerLoad; i++) {
      calendarDates
          .add(now.subtract(Duration(days: i))); //subtracting i days from now
    }
    setState(() {});
  }

  Future<void> loadPreviousDates() async {
    int newIndex = currentPageIndex + numDatesPerLoad;
    generateCalendarDates(newIndex);
    currentPageIndex = newIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchPhoto(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState != ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }

          return LazyLoadScrollView(
            onEndOfPage: loadPreviousDates,
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: calendarDates.length,
              reverse: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                final dateIndex = index;
                final formattedDate =
                    DateFormat('yyyy-MM-dd').format(calendarDates[dateIndex]);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPhoto(
                          dateId: formattedDate,
                          albumType: 'world',
                        ),
                      ),
                    ).then((_) {
                      // Re-fetch photos when navigating back to this screen
                      setState(() {
                        fetchPhoto();
                      });
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10.0),
                      image: datesToUrl![formattedDate] != null
                          ? DecorationImage(
                              image: NetworkImage(datesToUrl![formattedDate]!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('d').format(calendarDates[dateIndex]),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
