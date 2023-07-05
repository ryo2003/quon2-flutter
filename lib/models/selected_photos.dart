import 'package:cloud_firestore/cloud_firestore.dart';

class SelectedPhoto {
  final String id;
  final String imageUrl;
  final String uploaderUid;
  final String storedDate;
  final Timestamp createdAt;

  SelectedPhoto({
    required this.id,
    required this.imageUrl,
    required this.uploaderUid,
    required this.createdAt,
    required this.storedDate,
  });

  factory SelectedPhoto.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return SelectedPhoto(
      id: snapshot.id,
      imageUrl: data['imageUrl'] ?? '',
      storedDate: data['storedDate'] ?? '',
      uploaderUid: data['uploaderUid'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'uploaderUid': uploaderUid,
      'createdAt': createdAt,
      'storedDate': storedDate,
    };
  }
}
