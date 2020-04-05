import 'dart:io';

import 'package:blog_app/services/crud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class NewBlog extends StatefulWidget {
  @override
  _NewBlogState createState() => _NewBlogState();
}

class _NewBlogState extends State<NewBlog> {
  String Authname = "", title = "", desc = "";
  File selectedImage;
  bool _loading = false;
  CrudMethods crudMethods = new CrudMethods();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      //we want the selectedImage to be dynamic i.e change whenever user chooses different image
      selectedImage = image;
    });
  }

  updateBlog() async {
    if (selectedImage != null) {
      setState(() {
        _loading = true;
      });
      // uploading image  to firebase storage
      StorageReference blogImagesStorageReference = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(10)}.jpg");
      final StorageUploadTask task =
          blogImagesStorageReference.putFile(selectedImage);
      var downloadUrl = await (await task.onComplete).ref.getDownloadURL();

      print(" $downloadUrl");

      Map<String, String> blog = {
        "authorName": Authname,
        "desc": desc,
        "imgUrl": downloadUrl,
        "title": title,
        "time": DateTime.now().millisecondsSinceEpoch.toString()
      };
      crudMethods.addData(blog);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Flutter"),
            Text(
              "Blog",
              style: TextStyle(color: Colors.lightBlue),
            ),
          ],
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
                onTap: () {
                  updateBlog();
                  setState(() {});
                  //print("$Authname $title $desc");
                },
                child: Icon(Icons.file_upload)),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: <Widget>[
                    selectedImage == null
                        ? GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                selectedImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      onChanged: (val) {
                        Authname = val;
                      },
                      decoration: InputDecoration(hintText: "Author Name"),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      onChanged: (val) {
                        title = val;
                      },
                      decoration: InputDecoration(hintText: "Title"),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      onChanged: (val) {
                        desc = val;
                      },
                      decoration: InputDecoration(hintText: "Description"),
                    ),
                    Text("$Authname $title $desc")
                  ],
                ),
              ),
            ),
    );
  }
}
