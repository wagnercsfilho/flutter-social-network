import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

import '../models/user_model.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';

final storageRef = FirebaseStorage.instance.ref();
final postRef = Firestore.instance.collection('posts');

class UploadScreen extends StatefulWidget {
  final User currentUser;

  UploadScreen({Key key, this.currentUser}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File file;
  final picker = ImagePicker();
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController locationControler = TextEditingController();
  TextEditingController captionControler = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  handleTakePhoto() async {
    Navigator.pop(context);

    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxWidth: 960,
      maxHeight: 675,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() {
      this.file = File(pickedFile.path);
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      this.file = File(pickedFile.path);
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text('Image from Gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placemark = placemarks[0];
    String formatedAdress = "${placemark.locality}, ${placemark.country}";

    locationControler.text = formatedAdress;
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());

    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(
        imageFile,
        quality: 85,
      ));

    setState(() {
      file = compressedImageFile;
    });
  }

  uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);

    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;

    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    await compressImage();

    String mediaUrl = await uploadImage(file);

    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationControler.text,
      description: captionControler.text,
    );

    captionControler.clear();
    locationControler.clear();

    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    final timestamp = DateTime.now();

    postRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  buildSplashScreen() {
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Create post',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/upload.svg',
              height: 150,
            ),
            SizedBox(
              height: 48,
            ),
            RaisedButton(
              onPressed: () => selectImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Theme.of(context).accentColor,
            )
          ],
        ),
      ),
    );
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          isUploading ? linearProgress() : SizedBox(height: 0),
          Container(
            child: Image.file(
              file,
              fit: BoxFit.cover,
              height: 180.0,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 0),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                widget.currentUser.photoUrl,
              ),
            ),
            title: Container(
              child: TextField(
                controller: captionControler,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.only(left: 0),
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
            ),
            title: TextField(
              controller: locationControler,
              decoration: InputDecoration(
                hintText: 'Where was this photo taken?',
                border: InputBorder.none,
              ),
            ),
          ),
          Center(
            child: RaisedButton.icon(
              color: Theme.of(context).accentColor,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use Current Location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: file == null ? buildSplashScreen() : buildUploadForm(),
    );
  }
}
