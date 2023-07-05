import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/candidates_photo_model.dart';
import 'models/photo_model.dart';

class AddPhoto extends StatefulWidget {
  const AddPhoto({
    Key? key,
    required this.dateId,
    required this.albumType,
  }) : super(key: key);

  final String dateId;
  final String albumType;

  @override
  State<AddPhoto> createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  File? _image;
  String? _imageUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPhoto();
    });
  }

  Future<void> _deleteCandidatePhoto() async {
    final snapshot2 = await FirebaseFirestore.instance
        .collection('candidate_photos')
        .where('uploaderUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot2.docs.isNotEmpty) {
      // Delete photo data from Firestore
      await snapshot2.docs[0].reference.delete();
    }
  }

  Future<void> _deletePhoto() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('photos')
        .where('storedDate', isEqualTo: widget.dateId)
        .where('isWorld', isEqualTo: widget.albumType == "world")
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Delete image from Firebase Storage
      var imageUrl = snapshot.docs[0].data()['imageUrl'];
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();

      // Delete photo data from Firestore
      await snapshot.docs[0].reference.delete();

      // Clear local image url
      setState(() {
        _imageUrl = null;
      });
    }
  }

  Future<void> fetchPhoto() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('photos')
          .where('storedDate', isEqualTo: widget.dateId)
          .where('isWorld', isEqualTo: widget.albumType == "world")
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data =
            snapshot.docs[0].data() as Map<String, dynamic>;
        _imageUrl = data['imageUrl'];
      }
    } catch (e) {
      print('Error fetching photo: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<bool> _showUploadToWorldAlbumDialog() async {
    if (widget.albumType != 'personal') return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload to world album'),
          content: Text(
              'Do you want to upload this photo to the world album as well?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
                _deleteCandidatePhoto();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _uploadPhoto() async {
    if (_image == null) return;

    final addToWorldAlbum = await _showUploadToWorldAlbumDialog();

    setState(() {
      _uploading = true;
    });

    try {
      // Delete the old photo if exists
      await _deletePhoto();

      // Upload new photo to Firebase Storage and get the download URL
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('photos')
          .child(DateTime.now().toIso8601String());
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save photo data to Firestore

      final photo = Photo(
        id: "",
        createdAt: Timestamp.now(),
        uploaderUid: FirebaseAuth.instance.currentUser!.uid,
        imageUrl: downloadUrl,
        storedDate: widget.dateId,
        isWorld: widget.albumType == "world", //|| addToWorldAlbum,
      );

      if (addToWorldAlbum) {
        final candidatePhoto = CandidatePhoto(
          id: "",
          createdAt: Timestamp.now(),
          uploaderUid: FirebaseAuth.instance.currentUser!.uid,
          imageUrl: downloadUrl,
          storedDate: widget.dateId,
          numOfLikes: 0,
        );
        await FirebaseFirestore.instance
            .collection('candidate_photos')
            .add(candidatePhoto.toMap());

        await FirebaseFirestore.instance
            .collection('photos')
            .add(photo.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('photos')
            .add(photo.toMap());
      }

      // Navigate back to the previous screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload photo: ${e.toString()}'),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dateId} ${widget.albumType}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: fetchPhoto(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Text('Choose Photo'),
                  ),
                  if (_image == null && _imageUrl != null) ...[
                    const SizedBox(height: 20),
                    Image.network(_imageUrl!),
                  ],
                  if (_image != null) ...[
                    const SizedBox(height: 20),
                    Image.file(_image!),
                  ],
                  ElevatedButton(
                    onPressed: _uploading ? null : _uploadPhoto,
                    child: _uploading
                        ? const CircularProgressIndicator()
                        : const Text('Upload'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
