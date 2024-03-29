import 'package:cloud_firestore/cloud_firestore.dart';

class CandidatePhoto {
  final String id;
  final String imageUrl;
  final String uploaderUid;
  final String storedDate;
  final Timestamp createdAt;
  final int numOfLikes;

  CandidatePhoto({
    required this.id,
    required this.imageUrl,
    required this.uploaderUid,
    required this.createdAt,
    required this.storedDate,
    required this.numOfLikes,
  });

  factory CandidatePhoto.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CandidatePhoto(
      id: snapshot.id,
      imageUrl: data['imageUrl'] ?? '',
      storedDate: data['storedDate'] ?? '',
      uploaderUid: data['uploaderUid'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      numOfLikes: data['numOfLikes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'uploaderUid': uploaderUid,
      'createdAt': createdAt,
      'storedDate': storedDate,
      'numOfLikes': numOfLikes,
    };
  }
}
