import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPhoto extends StatefulWidget {
  const AddPhoto({
    super.key,
    required this.dateId,
    required this.albumType,
  });
  final String dateId;
  final String albumType;

  @override
  State<AddPhoto> createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  late String title;

  File? _image;
  bool _uploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _uploadPhoto() async {
    try {
      // Upload image to Firebase Storage and get the download URL
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('photos')
          .child(DateTime.now().toIso8601String());
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save photo data to Firestore
      // final photo = Photo(
      //   id: "",
      //   createdAt: Timestamp.now(),
      //   uploaderUid: FirebaseAuth.instance.currentUser!.uid,
      //   imageUrl: downloadUrl,
      //   albumId: widget.albumId,
      // );
      // await FirebaseFirestore.instance.collection('photos').add(photo.toMap());

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
        title: Text(widget.dateId + widget.albumType),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
                child: const Text('Choose Photo'),
              ),
              if (_image != null) ...[
                const SizedBox(height: 20),
                Image.file(_image!),
              ],
              ElevatedButton(
                onPressed: _uploadPhoto,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
