import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:happy_school/utils/hexcolor.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UploadAnnouncements extends StatefulWidget {
  const UploadAnnouncements({super.key});

  @override
  State<UploadAnnouncements> createState() => _UploadAnnouncementsState();
}

class _UploadAnnouncementsState extends State<UploadAnnouncements> {
  TextEditingController Announcement = TextEditingController();
  TextEditingController AnnouncementDescription = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  bool isloading = false;

  void _showDocumentIdPopup2(String documentId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(documentId),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
        onDateSelected(picked);
      });
    }
  }

  File? _image;

  @override
  void dispose() {
    Announcement.dispose();
    AnnouncementDescription.dispose();
    super.dispose();
  }

  Future<String> _getimageUrl() async {
    if (_image != null) {
      final fileExtension = _image?.path.split('.').last;
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('announcements/$uniqueFileName');
      UploadTask uploadTask = storageReference.putFile(_image!);

      try {
        await uploadTask; // Ensure upload completes before getting URL
        String imageURL = await storageReference.getDownloadURL();
        return imageURL;
      } catch (e) {
        print('Error uploading image: $e');
        return ''; // Return empty string if upload fails
      }
    } else {
      return ''; // No image to upload, return empty string
    }
  }

  Future<void> _uploadAnnouncement() async {
    // Fetch the image URL (if there is one)
    String imageUrl = await _getimageUrl();

    // Check that required fields are not empty
    if (Announcement.text.isNotEmpty &&
        AnnouncementDescription.text.isNotEmpty &&
        _fromDate != null &&
        _toDate != null) {
      try {
        // Upload the announcement data to Firestore
        await FirebaseFirestore.instance.collection('announcements').add({
          'title': Announcement.text,
          'description': AnnouncementDescription.text,
          'fromDate': _fromDate,
          'toDate': _toDate,
          'imageUrl': imageUrl,
          'createdAt': DateTime.now(),
        });

        // Show success message
        _showDocumentIdPopup2("Announcement Uploaded Successfully",
            "Your announcement has been uploaded.");
      } catch (error) {
        print('Error uploading announcement: $error');
      }
    } else {
      print("Please fill all required fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Upload New Announcement"),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          setState(() {
            isloading = true;
          });

          // Upload the announcement
          await _uploadAnnouncement();

          setState(() {
            isloading = false;
          });
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(color: Colors.orange),
          child: Center(
            child: Text(
              "Upload",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image input and display
                  _image != null
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.04,
                            top: width * 0.02,
                            right: width * 0.04,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 238, 222),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            height: width * 0.78,
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: HexColor('#2A2828'),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    height: width * 0.10,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: width * 0.02,
                                          left: width * 0.03,
                                          child: Text(
                                            "Announcement Banner",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: width * 0.03,
                                          top: width * 0.02,
                                          child: GestureDetector(
                                            onTap: _pickImageFromGallery,
                                            child: Text(
                                              "Edit",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: width * 0.1),
                                    child: Container(
                                      width: width,
                                      child: Image.file(
                                        _image!,
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: width * 0.02,
                                  left: width * 0.02,
                                  child: GestureDetector(
                                    onTap: _pickImageFromCamera,
                                    child: FaIcon(
                                      FontAwesomeIcons.camera,
                                      size: width * 0.06,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.04,
                            top: width * 0.02,
                            right: width * 0.04,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 238, 222),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            height: width * 0.78,
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: HexColor('#2A2828'),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    height: width * 0.10,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: width * 0.02,
                                          left: width * 0.03,
                                          child: Text(
                                            "Announcement Banner",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: width * 0.03,
                                          top: width * 0.02,
                                          child: GestureDetector(
                                            onTap: _pickImageFromGallery,
                                            child: Text(
                                              "Edit",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: width * 0.35,
                                  left: width * 0.33,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: _pickImageFromGallery,
                                        child: Image.asset(
                                          'assets/Images/Addphoto2.png',
                                          width: width * 0.13,
                                          height: width * 0.13,
                                        ),
                                      ),
                                      Text(
                                        "Click to Add Photo",
                                        style: TextStyle(
                                          fontSize: width * 0.03,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: width * 0.02,
                                  left: width * 0.02,
                                  child: GestureDetector(
                                    onTap: _pickImageFromCamera,
                                    child: FaIcon(
                                      FontAwesomeIcons.camera,
                                      size: width * 0.06,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  // Input fields for announcement title and description
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.04,
                        top: width * 0.02,
                        right: width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: width * 0.04),
                        TextField(
                          controller: Announcement,
                          decoration: InputDecoration(
                            labelText: 'Announcement Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: width * 0.04),
                        TextField(
                          controller: AnnouncementDescription,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Announcement Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: width * 0.04),
                        TextField(
                          controller: fromDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'From Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () {
                            _selectDate(context, fromDateController, (picked) {
                              _fromDate = picked;
                            });
                          },
                        ),
                        SizedBox(height: width * 0.04),
                        TextField(
                          controller: toDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: 'To Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today)),
                          onTap: () {
                            _selectDate(context, toDateController, (picked) {
                              _toDate = picked;
                            });
                          },
                        ),
                        SizedBox(height: width * 0.04),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
}
