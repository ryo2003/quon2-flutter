import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import 'package:quon2/add_photo.dart';

class WorldAlbum extends StatefulWidget {
  const WorldAlbum({super.key});
  static String id = 'world_album';
  static String title = 'World Album';

  @override
  State<WorldAlbum> createState() => _WorldAlbumState();
}

class _WorldAlbumState extends State<WorldAlbum> {
  List<DateTime> calendarDates = [];
  int currentPageIndex = 0;
  int numDatesPerLoad = 30; // Number of dates to generate in one batch

  @override
  void initState() {
    super.initState();
    generateCalendarDates(currentPageIndex);
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
    await Future.delayed(
        const Duration(seconds: 2)); // Simulating an async operation
    generateCalendarDates(newIndex);
    currentPageIndex = newIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LazyLoadScrollView(
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
            return GestureDetector(
              onTap: () {
                // Handle date tap event
                print(
                    'Tapped ${DateFormat('yyyy-MM-dd').format(calendarDates[dateIndex])}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPhoto(
                      dateId: DateFormat('yyyy-MM-dd')
                          .format(calendarDates[dateIndex]),
                      albumType: 'world',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0),
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
      ),
    );
  }
}
