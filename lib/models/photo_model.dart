import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  final String id;
  final String imageUrl;
  final String uploaderUid;
  final String storedDate;
  final Timestamp createdAt;
  final bool isWorld;

  Photo({
    required this.id,
    required this.imageUrl,
    required this.uploaderUid,
    required this.createdAt,
    required this.storedDate,
    required this.isWorld,
  });

  factory Photo.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Photo(
      id: snapshot.id,
      imageUrl: data['imageUrl'] ?? '',
      storedDate: data['storedDate'] ?? '',
      uploaderUid: data['uploaderUid'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isWorld: data['isWorld'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'uploaderUid': uploaderUid,
      'createdAt': createdAt,
      'storedDate': storedDate,
      'isWorld': isWorld,
    };
  }
}
