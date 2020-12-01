//Caution: Only works on Android & iOS platforms
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:overlay_support/overlay_support.dart';

//void main() => runApp(MyApp());
bool uploading = false;
String uploadText = "Upload Image";

CollectionReference newupload =
    FirebaseFirestore.instance.collection('newupload');
final Color yellow = Colors.amber;
final Color orange = Color(0xfffb6900);
void shownoti(s) {
  showSimpleNotification(Text(s), background: Colors.amber);
}

class UploadingImageToFirebaseStorage extends StatefulWidget {
  @override
  _UploadingImageToFirebaseStorageState createState() =>
      _UploadingImageToFirebaseStorageState();
}

class _UploadingImageToFirebaseStorageState
    extends State<UploadingImageToFirebaseStorage> {
  File _imageFile;
  var _progress = 0.0;
  var _uploaded = 0.0;
  var _toupload = 0.0;
  final nameInput = TextEditingController();

  ///NOTE: Only supported on Android & iOS
  ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future uploadImageToFirebase(BuildContext context) async {
    final text = await showTextInputDialog(
      context: context,
      textFields: const [
        DialogTextField(),
      ],
      title: 'Enter name',
      message: 'the system will save the name in database',
    );
    setState(() {
      uploading = true;
      uploadText = "Uploading...";
    });
    print(uploading);
    String personName = nameInput.text + ".jpg";

    String fileName = basename(_imageFile.path);
    if (personName == "") {
      personName = fileName;
    }
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$personName');
    print(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    uploadTask.events.listen((event) {
      setState(() {
        _progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
        _toupload = event.snapshot.totalByteCount.toDouble();
        _toupload = _toupload / 1024;
        _uploaded = event.snapshot.bytesTransferred.toDouble();
        _uploaded = _toupload / 1024;
      });
    });
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        value = newupload.add({"url": value, "name": text[0]});
        shownoti("upload done");
        uploading = false;
        setState(() {
          uploading = false;
          uploadText = "Upload Image";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: 360,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0)),
                gradient: LinearGradient(
                    colors: [orange, yellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 80),
            child: Column(
              children: <Widget>[
                LinearProgressIndicator(
                  value: _progress,
                ),
                Text(
                    "${(this._progress * 100).toInt()}% finished ${uploading}"),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Center(
                //       child: TextField(
                //     decoration: InputDecoration(
                //         border: InputBorder.none,
                //         hintText: 'Enter the name of the person'),
                //     controller: nameInput,
                //   )),
                // ),
                SizedBox(height: 20.0),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: _imageFile != null
                              ? Image.file(_imageFile)
                              : FlatButton(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                  ),
                                  onPressed: pickImage,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                uploadImageButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadImageButton(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            margin: const EdgeInsets.only(
                top: 30, left: 20.0, right: 20.0, bottom: 20.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [yellow, orange],
                ),
                borderRadius: BorderRadius.circular(30.0)),
            child: FlatButton(
              onPressed: () =>
                  _imageFile == null ? null : uploadImageToFirebase(context),
              child: Text(
                uploadText,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
