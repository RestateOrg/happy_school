import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Userpostupload extends StatefulWidget {
  final String username; // Use final
  final String email; // Use final
  const Userpostupload({Key? key, required this.username, required this.email})
      : super(key: key);

  @override
  State<Userpostupload> createState() => _UserpostuploadState();
}

class _UserpostuploadState extends State<Userpostupload> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _image;
  bool _isLoading = false;
  String? _selectedTag; // Holds the selected tag

  final User? user = FirebaseAuth.instance.currentUser;
  String desig = '';
  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<void> getUsername() async {
    try {
      var userDocument = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.email)
          .collection('userinfo')
          .doc('userinfo')
          .get();

      if (userDocument.exists) {
        setState(() {
          desig = userDocument.get('role');
        });
      }
    } catch (e) {
      print("Error getting username: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _getimageUrl() async {
    if (_image == null) {
      return '';
    }

    // Generate a unique ID using UUID
    String uniqueId = const Uuid().v4();

    // Reference for Firebase Storage with the unique file name
    final ref =
        FirebaseStorage.instance.ref().child('posts').child('$uniqueId.jpg');

    try {
      // List all items in the 'posts' folder
      final listResult = await FirebaseStorage.instance.ref('posts').listAll();

      // Check if any file matches the unique ID
      final fileExists =
          listResult.items.any((item) => item.name == '$uniqueId.jpg');

      if (fileExists) {
        // If file exists, return its download URL
        return await ref.getDownloadURL();
      }
    } catch (e) {
      // Handle other exceptions here
      rethrow;
    }

    // Upload the image if no file exists with the same ID
    await ref.putFile(_image!);

    // Return the download URL of the newly uploaded file
    return await ref.getDownloadURL();
  }

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

  Future<void> _uploadPost() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      String imageUrl = await _getimageUrl();

      if (_titleController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
          _image != null &&
          _selectedTag != null) {
        // Ensure tag is selected
        try {
          // Upload the post data to Firestore
          await FirebaseFirestore.instance.collection('Posts').add({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'tag': _selectedTag,
            'createdAt': Timestamp.now(),
            'likes': 0,
            'comments': [],
            'imageUrl': imageUrl,
            'user': widget.username,
            'designation': desig,
          });

          // Show success message
          _showDocumentIdPopup2(
              "Post Uploaded Successfully", "Your Post has been uploaded.");
        } catch (error) {
          print('Error uploading post: $error');
        }
      } else {
        print("Please fill all required fields");
      }
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully!')),
      );

      // Reset the form after submission
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _image = null;
        _selectedTag = null; // Reset tag selection
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload Post'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Create a Post",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: _image != null
                                  ? Image.file(_image!, fit: BoxFit.cover)
                                  : const Text(
                                      'Tap to add image',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Post Title',
                            labelStyle: const TextStyle(color: Colors.orange),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Colors.orange),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a post title';
                            }
                            return null;
                          },
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) {
                                if (newValue.text.isNotEmpty) {
                                  // Capitalize the first letter of the text
                                  String firstLetterCapitalized =
                                      newValue.text[0].toUpperCase() +
                                          newValue.text.substring(1);
                                  return newValue.copyWith(
                                      text: firstLetterCapitalized);
                                }
                                return newValue;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        // Description input
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: const TextStyle(color: Colors.orange),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Colors.orange),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        // Dropdown for Tag
                        DropdownButtonFormField<String>(
                          value: _selectedTag,
                          hint: const Text('Select Tag'),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: 'Tag',
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            labelStyle: const TextStyle(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Colors.orange),
                            ),
                          ),
                          items: ['Announcement', 'Update', 'Achievement']
                              .map((tag) => DropdownMenuItem(
                                    value: tag,
                                    child: Text(tag),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTag = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a tag' : null,
                        ),

                        const SizedBox(height: 24.0),
                        // Upload button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : GestureDetector(
                                onTap: _uploadPost,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: Text(
                                          'Upload Post',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
