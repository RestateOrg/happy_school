import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:happy_school/utils/hexcolor.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadCourse extends StatefulWidget {
  const UploadCourse({super.key});

  @override
  State<UploadCourse> createState() => _UploadCourseState();
}

class _UploadCourseState extends State<UploadCourse> {
  Map<String, dynamic> modules = {};
  TextEditingController courseName = TextEditingController();
  TextEditingController courseDescription = TextEditingController();
  final TextEditingController faqQuestionController = TextEditingController();
  final TextEditingController faqAnswerController = TextEditingController();
  bool isloading = false;

  List<Map<String, String>> userFaqs = [];

  void _addFAQ() {
    if (faqQuestionController.text.isNotEmpty &&
        faqAnswerController.text.isNotEmpty) {
      setState(() {
        userFaqs.add({
          'question': faqQuestionController.text,
          'answer': faqAnswerController.text,
        });
        faqQuestionController.clear();
        faqAnswerController.clear();
      });
    }
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

  File? _image;

  @override
  void dispose() {
    courseName.dispose();
    super.dispose();
  }

  void _addContent(String moduleName, String contentType) {
    if (contentType == 'PDF') {
      final fileName = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add PDF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fileName,
                  decoration: const InputDecoration(
                    hintText: 'Enter file name',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null) {
                      File file = File(result.files.single.path!);
                      // Handle the logic to add PDF content
                      final pdfContent = {
                        'fileName': fileName.text,
                        'file': file,
                      };
                      modules[moduleName]['content'].add(pdfContent);
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                  child: const Text('Upload PDF'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
    if (contentType == 'Image') {
      final fileName = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Image'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fileName,
                  decoration: const InputDecoration(
                    hintText: 'Enter file name',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null) {
                      File file = File(result.files.single.path!);
                      // Handle the logic to add image content
                      final imageContent = {
                        'fileName': fileName.text,
                        'file': file,
                      };
                      modules[moduleName]['content'].add(imageContent);
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                  child: const Text('Upload Image'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
    if (contentType == 'PPT') {
      final fileName = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add PPT'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fileName,
                  decoration: const InputDecoration(
                    hintText: 'Enter file name',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pptx'],
                    );
                    if (result != null) {
                      File file = File(result.files.single.path!);
                      // Handle the logic to add PDF content
                      final pdfContent = {
                        'fileName': fileName.text,
                        'file': file,
                      };
                      modules[moduleName]['content'].add(pdfContent);
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                  child: const Text('Upload PPT'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
    if (contentType == 'Video') {
      final fileName = TextEditingController();
      final youtubeUrl = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Video'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fileName,
                  decoration: const InputDecoration(
                    hintText: 'Enter file name',
                  ),
                ),
                TextField(
                  controller: youtubeUrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter YouTube URL',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Handle the logic to add video content
                  final videoContent = {
                    'fileName': fileName.text,
                    'youtubeUrl': youtubeUrl.text,
                    'type': "video",
                  };
                  modules[moduleName]['content'].add(videoContent);
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<String> _getimageUrl() async {
    if (_image != null) {
      final fileExtension = _image?.path.split('.').last;
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('course/$uniqueFileName');
      UploadTask uploadTask = storageReference.putFile(_image!);

      try {
        await uploadTask; // Ensure upload completes before getting URL
        String imageURL = await storageReference.getDownloadURL();
        return imageURL;
      } catch (e) {
        // Handle any errors during upload
        print('Error uploading image: $e');
        return ''; // Return empty string if upload fails
      }
    } else {
      return ''; // No image to upload, return empty string
    }
  }

  Future<void> UploadtoFirebase() async {
    final String coursename = courseName.text.trim();
    if (coursename.isEmpty) {
      print("Course name cannot be empty.");
      return;
    }

    try {
      String courseBannerURL = await _getimageUrl();

      final courseRef = FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("Courses")
          .doc(coursename);

      final courseNamesRef = FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("courseNames")
          .doc("courseNames");

      final courseNamesDoc = await courseNamesRef.get();
      final Map<String, dynamic> courseNamesData = courseNamesDoc.data() ?? {};

      String uniqueCourseId;
      do {
        uniqueCourseId = DateTime.now().millisecondsSinceEpoch.toString();
      } while (courseNamesData.containsKey(uniqueCourseId));

      courseNamesData[uniqueCourseId] = coursename;
      await courseNamesRef.set(courseNamesData);

      final List<Map<String, dynamic>> faqsForFirestore = userFaqs.map((faq) {
        return {
          'question': faq['question'],
          'answer': faq['answer'],
        };
      }).toList();

      await courseRef.collection("courseinfo").doc("info").set({
        "courseName": coursename,
        "courseId": uniqueCourseId,
        "courseImage": courseBannerURL,
        "courseDescription": courseDescription.text.trim(),
        "faqs": faqsForFirestore,
      });

      int serialNumber = 1;

      for (var module in modules.entries) {
        final String moduleName = module.key;
        final Map<String, dynamic> moduleData = module.value;
        final List<dynamic> moduleContent = moduleData['content'] ?? [];

        final moduleRef = courseRef.collection("Modules").doc(moduleName);

        for (var content in moduleContent) {
          final String fileName = content['fileName'];

          if (content['type'] == 'video') {
            final String youtubeUrl = content['youtubeUrl'];
            await moduleRef.set({
              's.no': serialNumber,
              fileName: youtubeUrl,
            }, SetOptions(merge: true));
          } else {
            final File file = content['file'];
            final String fileExtension = file.path.split('.').last;
            final String fullFileName = '$fileName.$fileExtension';

            final storageRef = FirebaseStorage.instance
                .ref()
                .child('Coursecontent/$coursename/$moduleName/$fullFileName');
            await storageRef.putFile(file);

            final String downloadURL = await storageRef.getDownloadURL();

            await moduleRef.set({
              's.no': serialNumber,
              fileName: downloadURL,
            }, SetOptions(merge: true));
          }
        }

        serialNumber++;
      }

      print("Course and modules uploaded successfully.");
    } catch (e) {
      print("Failed to upload course: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Upload New Course"),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          setState(() {
            isloading = true;
          });
          await UploadtoFirebase();
          setState(() {
            isloading = false;
          });
          _showDocumentIdPopup2("Course Uploaded Successfully",
              "Your Have Successfully Uploaded the Course");
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
                  // Image picker and display
                  _image != null
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.04,
                            top: width * 0.02,
                            right: width * 0.04,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 249, 222),
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
                                            "Course Banner",
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
                              color: Color.fromARGB(255, 255, 249, 222),
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
                                            "Course Banner",
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

                  // Course name input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: courseName,
                        decoration: const InputDecoration(
                          hintText: 'Enter Course Name',
                          labelText: 'Enter Course Name',
                        ),
                      ),
                    ),
                  ),

                  // Course description input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: courseDescription,
                        decoration: const InputDecoration(
                          hintText: 'Enter Course Description',
                          labelText: 'Enter Course Description',
                        ),
                      ),
                    ),
                  ),

                  // Add module button
                  Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: GestureDetector(
                          onTap: () {
                            final moduleName = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Add Module'),
                                  content: TextField(
                                    controller: moduleName,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter module name',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        modules[moduleName.text] = {
                                          'expanded': false,
                                          'content': []
                                        };
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orange,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Add Module"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      height: modules.isEmpty ? 40 : 300,
                      child: modules.isEmpty
                          ? const Center(child: Text("No Modules Yet"))
                          : ListView(
                              children: modules.keys.map((String key) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      modules[key]['expanded'] =
                                          !modules[key]['expanded'];
                                    });
                                  },
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            key,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Row(
                                            children: [
                                              Spacer(),
                                              PopupMenuButton<String>(
                                                onSelected: (String result) {
                                                  _addContent(key, result);
                                                },
                                                itemBuilder: (BuildContext
                                                        context) =>
                                                    <PopupMenuEntry<String>>[
                                                  const PopupMenuItem<String>(
                                                    value: 'PDF',
                                                    child: Text('PDF'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: 'PPT',
                                                    child: Text('PPT'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: 'Image',
                                                    child: Text('Image'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: 'Video',
                                                    child: Text('Video'),
                                                  ),
                                                ],
                                                icon: Icon(Icons.add),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      modules.remove(key);
                                                    });
                                                  },
                                                  child: Icon(Icons.delete),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (modules[key]['expanded'])
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: List<Widget>.from(
                                                  modules[key]['content'].map(
                                                      (contentType) => Text(
                                                          '• $contentType')),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),

                  // FAQ input section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: faqQuestionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter FAQ Question',
                        labelText: 'FAQ Question',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: faqAnswerController,
                      decoration: const InputDecoration(
                        hintText: 'Enter FAQ Answer',
                        labelText: 'FAQ Answer',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: _addFAQ,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Center(child: Text('Add FAQ')),
                      ),
                    ),
                  ),

                  // Display FAQ list
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('FAQs', style: TextStyle(fontSize: 18)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: userFaqs.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        child: ExpansionTile(
                          title: Text(userFaqs[index]['question'] ?? ''),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userFaqs[index]['answer'] ?? '',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8.0),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Remove FAQ from the list
                                        setState(() {
                                          userFaqs.removeAt(index);
                                        });
                                      },
                                      child: Text('Remove'),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Colors.red, // Text color
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }

  Future _pickImageFromGallery() async {
    final pickedimage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedimage!.path);
    });
  }

  Future _pickImageFromCamera() async {
    final pickedimage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedimage!.path);
    });
  }
}
