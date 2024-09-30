import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/utils/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

class EditCoursePage extends StatefulWidget {
  final String courseName;

  const EditCoursePage({required this.courseName, super.key});

  @override
  _EditCoursePageState createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  Map<String, dynamic> modules = {};
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseDescriptionController = TextEditingController();
  final TextEditingController faqQuestionController = TextEditingController();
  final TextEditingController faqAnswerController = TextEditingController();
  List<Map<String, String>> userFaqs = [];
  bool isLoading = false;
  String courseImage = '';
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchCourseData();
  }

  Future<void> UploadtoFirebase() async {
    String courseBannerURL;
    final String coursename = courseNameController.text.trim();
    if (coursename.isEmpty) {
      print("Course name cannot be empty.");
      return;
    }

    try {
      if (_image != null) {
        courseBannerURL = await _getimageUrl();
      } else {
        courseBannerURL = courseImage;
      }

      // Reference to the course document
      final courseRef = FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("Courses")
          .doc(coursename);

      // Check if the course already exists
      final courseDoc = await courseRef.get();

      if (courseDoc.exists) {
        // Course exists, update the existing document
        print("Updating existing course: $coursename");

        // Prepare FAQs for Firestore
        final List<Map<String, dynamic>> faqsForFirestore = userFaqs.map((faq) {
          return {
            'question': faq['question'],
            'answer': faq['answer'],
          };
        }).toList();

        // Update course information
        await courseRef.collection("courseinfo").doc("info").set({
          "courseName": coursename,
          "courseImage": courseBannerURL,
          "courseDescription": courseDescriptionController.text.trim(),
          "faqs": faqsForFirestore,
        }, SetOptions(merge: true));

        // Update modules and their content
        await _updateModules(courseRef, coursename);

        print("Course updated successfully.");
      } else {
        // Course doesn't exist, create a new one
        print("Creating new course: $coursename");

        // Generate a unique course ID
        String uniqueCourseId;
        do {
          uniqueCourseId = DateTime.now().millisecondsSinceEpoch.toString();
        } while ((await FirebaseFirestore.instance
                .collection("Content")
                .doc("Content")
                .collection("courseNames")
                .doc("courseNames")
                .get())
            .data()!
            .containsKey(uniqueCourseId));

        // Upload new course information
        await courseRef.collection("courseinfo").doc("info").set({
          "courseName": coursename,
          "courseId": uniqueCourseId,
          "courseImage": courseBannerURL,
          "courseDescription": courseDescriptionController.text.trim(),
          "faqs": userFaqs,
        });

        // Upload modules and their content
        await _uploadModules(courseRef, coursename);

        // Update course names
        await _updateCourseNames(uniqueCourseId, coursename);

        print("Course created successfully.");
      }
    } catch (e) {
      // Handle any errors
      print("Failed to upload course: $e");
    }
  }

  Future<void> _uploadModules(
      DocumentReference courseRef, String coursename) async {
    int moduleSerialNumber = 1;

    for (var module in modules.entries) {
      final String moduleName = module.key;
      final Map<String, dynamic> moduleData = module.value;
      final List<dynamic> moduleContent = moduleData['content'] ?? [];

      final moduleRef = courseRef.collection("Modules").doc(moduleName);
      int contentSerialNumber = 1;

      // Create a map for the module content with serial numbers
      Map<String, dynamic> moduleContentData = {'s.no': moduleSerialNumber};

      for (var content in moduleContent) {
        final String fileName = content['fileName'];

        if (content.containsKey('url')) {
          // Handle YouTube video URLs
          final String youtubeUrl = content['url'];
          moduleContentData[fileName] = {
            'url': youtubeUrl,
            's.no': contentSerialNumber,
          };
        } else {
          // Handle file uploads
          final File file = content['file'];
          final String fileExtension = file.path.split('.').last;
          final String fullFileName = '$fileName.$fileExtension';

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('Coursecontent/$coursename/$moduleName/$fullFileName');

          // Upload file to Firebase Storage
          await storageRef.putFile(file);

          // Get the download URL
          final String downloadURL = await storageRef.getDownloadURL();
          moduleContentData[fileName] = {
            'url': downloadURL,
            's.no': contentSerialNumber,
          };
        }

        contentSerialNumber++;
      }

      // Upload the module content to Firestore
      await moduleRef.set(moduleContentData, SetOptions(merge: true));
      moduleSerialNumber++;
    }
  }

  Future<void> _updateModules(
      DocumentReference courseRef, String coursename) async {
    int moduleSerialNumber = 1;

    for (var module in modules.entries) {
      final String moduleName = module.key;
      final Map<String, dynamic> moduleData = module.value;
      final List<dynamic> moduleContent = moduleData['content'] ?? [];

      final moduleRef = courseRef.collection("Modules").doc(moduleName);
      int contentSerialNumber = 1;

      // Create a map for the module content with serial numbers
      Map<String, dynamic> moduleContentData = {'s.no': moduleSerialNumber};

      for (var content in moduleContent) {
        final String fileName = content['fileName'];
        final String url = content['url']; // Assuming 'url' is stored here

        if (url.contains('youtu.be')) {
          // Handle YouTube video URLs
          moduleContentData[fileName] = {
            'url': url,
            's.no': contentSerialNumber,
          };
        } else {
          // Handle file uploads
          final File file = content['file'];
          final String fileExtension = file.path.split('.').last;
          final String fullFileName = '$fileName.$fileExtension';

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('Coursecontent/$coursename/$moduleName/$fullFileName');

          // Upload file to Firebase Storage
          await storageRef.putFile(file);

          // Get the download URL
          final String downloadURL = await storageRef.getDownloadURL();
          moduleContentData[fileName] = {
            'url': downloadURL,
            's.no': contentSerialNumber,
          };
        }

        contentSerialNumber++;
      }

      // Upload the module content to Firestore
      await moduleRef.set(moduleContentData, SetOptions(merge: true));
      moduleSerialNumber++;
    }
  }

  Future<void> _updateCourseNames(
      String uniqueCourseId, String coursename) async {
    final courseNamesRef = FirebaseFirestore.instance
        .collection("Content")
        .doc("Content")
        .collection("courseNames")
        .doc("courseNames");

    // Ensure the courseNames document exists
    await courseNamesRef.set({}, SetOptions(merge: true));

    // Get existing course names data
    final courseNamesDoc = await courseNamesRef.get();
    final Map<String, dynamic> courseNamesData = courseNamesDoc.data() ?? {};

    // Check if the course name already exists in any value
    if (!courseNamesData.containsValue(coursename)) {
      // Update courseNames document with the new course name if it doesn't exist
      courseNamesData[uniqueCourseId] = coursename;
      await courseNamesRef.set(courseNamesData);
    } else {
      print("Course name already exists and does not need updating.");
    }
  }

  void _addContent(String moduleName, String contentType) {
    final fileNameController = TextEditingController();
    final videoUrlController =
        TextEditingController(); // New controller for video URL

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $contentType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fileNameController,
                decoration: InputDecoration(
                  hintText: 'Enter file name',
                ),
              ),
              if (contentType == 'Video') // Show video URL field only for Video
                TextField(
                  controller: videoUrlController,
                  decoration: InputDecoration(
                    hintText: 'Enter video URL',
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  if (contentType == 'Video') {
                    // Handle video URL case
                    String videoUrl = videoUrlController.text.trim();
                    if (videoUrl.isNotEmpty) {
                      int maxSNo = 0;

                      // Ensure that the module exists before trying to access it
                      if (modules[moduleName] != null) {
                        modules[moduleName].forEach((key, value) {
                          if (value is Map &&
                              value.containsKey('s.no') &&
                              value['s.no'] is int) {
                            // Update maxSNo if the current s.no is greater
                            if (value['s.no'] > maxSNo) {
                              maxSNo = value['s.no'];
                            }
                          }
                        });
                      }

                      // Create new content entry for video
                      final newContent = {
                        's.no': maxSNo + 1,
                        'url': videoUrl,
                      };

                      // Construct the new key for the content type and file name
                      String newKey = '${fileNameController.text}';

                      // Ensure that the new content key does not already exist
                      if (modules[moduleName][newKey] == null) {
                        // Add the new video content
                        modules[moduleName][newKey] = newContent;
                      } else {
                        // Handle the case where the key already exists
                        print(
                            "Content with the key $newKey already exists in $moduleName.");
                      }
                    }
                  } else {
                    // Handle file uploads for PDF, PPT, or Image
                    FilePickerResult? result;
                    if (contentType == 'PDF') {
                      result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                    } else if (contentType == 'Image') {
                      result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                    } else if (contentType == 'PPT') {
                      result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pptx'],
                      );
                    }

                    if (result != null && result.files.isNotEmpty) {
                      File file = File(result.files.single.path!);

                      int maxSNo = 0;

                      // Ensure that the module exists before trying to access it
                      if (modules[moduleName] != null) {
                        modules[moduleName].forEach((key, value) {
                          if (value is Map &&
                              value.containsKey('s.no') &&
                              value['s.no'] is int) {
                            // Update maxSNo if the current s.no is greater
                            if (value['s.no'] > maxSNo) {
                              maxSNo = value['s.no'];
                            }
                          }
                        });
                      }

                      // Create new content entry for the file
                      final newContent = {
                        's.no': maxSNo + 1,
                        'file': file,
                      };

                      // Construct the new key for the content type and file name
                      String newKey = '${fileNameController.text}';

                      // Ensure that the new content key does not already exist
                      if (modules[moduleName][newKey] == null) {
                        // Add the new content based on the content type
                        modules[moduleName][newKey] = newContent;
                        print(modules[moduleName]);
                      } else {
                        // Handle the case where the key already exists
                        print(
                            "Content with the key $newKey already exists in $moduleName.");
                      }
                    }
                  }

                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: const Text('Add Content'),
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

  Future<void> fetchCourseData() async {
    try {
      // Fetch the course information
      DocumentSnapshot courseInfoDoc = await FirebaseFirestore.instance
          .collection('Content')
          .doc('Content')
          .collection('Courses')
          .doc(widget.courseName)
          .collection('courseinfo')
          .doc('info')
          .get();

      if (courseInfoDoc.exists) {
        var courseData = courseInfoDoc.data() as Map<String, dynamic>;
        setState(() {
          // Populate course name, description, image, and FAQs
          courseNameController.text = courseData['courseName'] ?? '';
          courseDescriptionController.text =
              courseData['courseDescription'] ?? '';
          courseImage = courseData['courseImage'] ?? '';

          if (courseData['faqs'] != null) {
            List<dynamic> faqsList = courseData['faqs'];
            userFaqs = faqsList.map((faq) {
              return {
                'question': faq['question']?.toString() ?? '',
                'answer': faq['answer']?.toString() ?? '',
              };
            }).toList();
          }
        });

        // Fetch the modules
        QuerySnapshot modulesSnapshot = await FirebaseFirestore.instance
            .collection('Content')
            .doc('Content')
            .collection('Courses')
            .doc(widget.courseName)
            .collection('Modules')
            .get();

        for (var moduleDoc in modulesSnapshot.docs) {
          var moduleData = moduleDoc.data() as Map<String, dynamic>;
          print(moduleData);
          modules[moduleDoc.id] = moduleData;
        }

        setState(() {
          isLoading = false;
        });
      } else {
        print("Course not found!");
      }
    } catch (e) {
      print("Error fetching course data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Edit Course'),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          setState(() {
            isLoading = true;
          });
          await UploadtoFirebase();
          setState(() {
            isLoading = false;
          });
          _showDocumentIdPopup2("Changes to the Course have been saved",
              "Changes have been uploaded.");
        },
        child: Container(
            color: Colors.orange,
            height: 70,
            child: Center(
                child: Text("Upload Changes",
                    style: TextStyle(fontSize: 20, color: Colors.white)))),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Image
                  if (_image != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: width * 0.02,
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
                  else
                    Padding(
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
                                  child:
                                      CachedNetworkImage(imageUrl: courseImage),
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
                    ),

                  // Course Name TextField
                  TextField(
                    controller: courseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Course Description TextField
                  TextField(
                    controller: courseDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Course Description',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // FAQs Input Section
                  Text('Add FAQ:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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

                  GestureDetector(
                    onTap: _addFAQ,
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 28, right: 28, top: 14, bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text("Add FAQ"),
                    ),
                  ),

                  // FAQs List
                  Text('FAQs:', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (userFaqs.isEmpty)
                    const Center(child: Text("No FAQs Yet"))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Prevent scrolling
                      itemCount: userFaqs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(userFaqs[index]['question']!),
                          subtitle: Text(userFaqs[index]['answer']!),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                userFaqs.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),

                  // Modules List
                  Row(
                    children: [
                      Text('Modules:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          final TextEditingController moduleNameController =
                              TextEditingController();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Add Module'),
                                content: TextField(
                                  controller: moduleNameController,
                                  decoration: InputDecoration(
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
                                  ElevatedButton(
                                    onPressed: () {
                                      final String moduleName =
                                          moduleNameController.text.trim();
                                      if (moduleName.isNotEmpty) {
                                        setState(() {
                                          modules[moduleName] = <String,
                                              dynamic>{}; // Explicitly define the type
                                        });
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Add Module'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  if (modules.isEmpty)
                    const Center(child: Text("No Modules Yet"))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Prevent scrolling
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        String moduleName = modules.keys.elementAt(index);
                        Map<String, dynamic> moduleContentData =
                            modules[moduleName]; // Getting the module data

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 238, 222),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Module Header
                                Container(
                                  decoration: BoxDecoration(
                                    color: HexColor('#2A2828'),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    moduleName,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                // Display module content
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (moduleContentData != null)
                                        ...(() {
                                          // Convert entries to a list and sort by 's.no'
                                          var sortedEntries = moduleContentData
                                              .entries
                                              .where((entry) =>
                                                  entry.key != 's.no')
                                              .toList();
                                          sortedEntries.sort((a, b) {
                                            int serialA = a.value['s.no'];
                                            int serialB = b.value['s.no'];
                                            return serialA.compareTo(serialB);
                                          });
                                          return sortedEntries
                                              .map<Widget>((entry) {
                                            String fileName = entry.key;
                                            Map<String, dynamic> contentData =
                                                entry.value;
                                            String contentUrl =
                                                contentData['url']
                                                        ?.toString() ??
                                                    '';
                                            int serialNumber =
                                                contentData['s.no'];

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                        '($serialNumber) $fileName'),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(contentUrl
                                                            .contains(
                                                                'youtu.be')
                                                        ? Icons.play_arrow
                                                        : contentUrl.contains(
                                                                '.pdf')
                                                            ? Icons
                                                                .picture_as_pdf
                                                            : contentUrl
                                                                    .contains(
                                                                        '.ppt')
                                                                ? Icons
                                                                    .slideshow
                                                                : contentUrl
                                                                        .contains(
                                                                            '.jpg')
                                                                    ? Icons
                                                                        .image
                                                                    : Icons
                                                                        .insert_drive_file),
                                                    onPressed: () {
                                                      // Handle file opening here
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList();
                                        })(),
                                      // Popup Menu for adding content
                                      Row(
                                        children: [
                                          Spacer(),
                                          PopupMenuButton<String>(
                                            onSelected: (String result) {
                                              _addContent(moduleName, result);
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
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
                                                  modules.remove(moduleName);
                                                });
                                              },
                                              child: Icon(Icons.delete),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
}
