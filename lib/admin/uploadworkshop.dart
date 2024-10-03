import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:happy_school/utils/hexcolor.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UploadWorkshop extends StatefulWidget {
  const UploadWorkshop({super.key});

  @override
  State<UploadWorkshop> createState() => _UploadWorkshopState();
}

class _UploadWorkshopState extends State<UploadWorkshop> {
  Map<String, dynamic> modules = {};
  TextEditingController courseName = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController workshopdescription = TextEditingController();
  bool isloading = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  File? _image;

  @override
  void dispose() {
    courseName.dispose();
    super.dispose();
  }

  void _addContent(String moduleName, String contentType) {
    if (contentType == 'Opinions') {
      // Provide the option for either video or image upload
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Opinion Content'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addContent(moduleName, 'Video');
                  },
                  child: const Text('Upload Video'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addContent(moduleName, 'Image');
                  },
                  child: const Text('Upload Photo'),
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
    } else if (contentType == 'Video') {
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
    } else if (contentType == 'Image') {
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
    if (contentType == 'Poll') {
      final pollQuestionController = TextEditingController();
      final pollOptionsControllers = <TextEditingController>[];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Add Poll'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: pollQuestionController,
                        decoration: const InputDecoration(
                          hintText: 'Enter poll question',
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height:
                            130, // Set a limited height for the options list
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Display each option with a remove button
                              for (var i = 0;
                                  i < pollOptionsControllers.length;
                                  i++)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: pollOptionsControllers[i],
                                        decoration: InputDecoration(
                                          hintText: 'Option ${i + 1}',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () {
                                        setState(() {
                                          pollOptionsControllers.removeAt(i);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            pollOptionsControllers.add(TextEditingController());
                          });
                        },
                        child: const Text('Add Option'),
                      ),
                    ],
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
                      // Handle the logic to add poll content
                      final pollOptions = pollOptionsControllers
                          .map((controller) => controller.text)
                          .toList();
                      final pollContent = {
                        'question': pollQuestionController.text,
                        'options': pollOptions,
                        'type': "poll",
                      };
                      modules[moduleName]['content'].add(pollContent);
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    child: const Text('Add Poll'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
    if (contentType == 'Form') {
      final formUrlController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Form URL'),
            content: TextField(
              controller: formUrlController,
              decoration: const InputDecoration(
                hintText: 'Enter Form URL',
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
                  // Handle the logic to add form URL content
                  final formContent = {
                    'formUrl': formUrlController.text,
                    'type': "form",
                  };
                  modules[moduleName]['content'].add(formContent);
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: const Text('Add Form'),
              ),
            ],
          );
        },
      );
    }
    if (contentType == 'Note') {
      final noteController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Note'),
            content: TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Enter your note',
              ),
              maxLines: 5,
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
                  // Handle the logic to add a note
                  final noteContent = {
                    'note': noteController.text,
                    'type': "note",
                  };
                  modules[moduleName]['content'].add(noteContent);
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: const Text('Add Note'),
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
    final coursename = courseName.text.trim();
    String courseBannerURL = await _getimageUrl();

    // Validate the course name
    if (coursename.isEmpty) {
      print("Course name cannot be empty.");
      return;
    }

    final courseRef = FirebaseFirestore.instance
        .collection("Content")
        .doc("Content")
        .collection("Challenges")
        .doc(coursename); // Using course name as document ID

    try {
      // Generate a unique course ID
      final courseNamesRef = FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("ChallengeNames")
          .doc("ChallengeNames");

      final courseNamesDoc = await courseNamesRef.get();
      final courseNamesData = courseNamesDoc.data() ?? {};

      // Check for a unique course ID
      String uniqueCourseId;
      do {
        uniqueCourseId = DateTime.now().millisecondsSinceEpoch.toString();
      } while (courseNamesData.containsKey(uniqueCourseId));

      // Add course name to the courseNames document
      courseNamesData[uniqueCourseId] = coursename;
      await courseNamesRef.set(courseNamesData);

      // Set the course info
      await courseRef.collection("challengeinfo").doc("info").set({
        "ChallengeName": coursename,
        "ChallengeDescription": workshopdescription.text,
        "ChallengeId": uniqueCourseId,
        "ChallengeImage": courseBannerURL,
        "FromDate": _fromDate != null ? _fromDate!.toIso8601String() : null,
        "ToDate": _toDate != null ? _toDate!.toIso8601String() : null,
      });

      for (var module in modules.entries) {
        final moduleName = module.key;
        final moduleData = module.value;
        final moduleContent = moduleData['content'];
        final taskUpto = moduleData['taskUpto']; // Task Upto Date

        // Reference to the module document
        final moduleRef = courseRef.collection("Tasks").doc(moduleName);

        for (var content in moduleContent) {
          final fileName = content['fileName'];

          if (content.containsKey('type') && content['type'] == 'video') {
            // Handle video content with YouTube URL
            final youtubeUrl = content['youtubeUrl'];

            // Create a document in Firestore with video details
            final documentData = {
              fileName.toString(): youtubeUrl,
            };
            await moduleRef.set(documentData, SetOptions(merge: true));
          } else {
            // Handle other types of files
            final file = content['file'];

            // Extract the file extension from the path
            final fileExtension = file.path.split('.').last;
            final fullFileName = '$fileName.$fileExtension';

            // Upload file to Firebase Storage with correct extension
            final storageRef = FirebaseStorage.instance.ref().child(
                'Challengecontent/$coursename/$moduleName/$fullFileName');
            await storageRef.putFile(file);

            // Get the download URL of the uploaded file
            final downloadURL = await storageRef.getDownloadURL();

            // Create a document in Firestore with the file details
            final documentData = {
              fileName.toString(): downloadURL,
            };
            await moduleRef.set(documentData, SetOptions(merge: true));
          }
        }

        // Add the "Task Upto" date to the module document
        await moduleRef.set({
          'taskUpto': taskUpto != null ? taskUpto.toIso8601String() : null,
        }, SetOptions(merge: true));
      }

      print("Files and task dates uploaded successfully.");
    } catch (e) {
      print("Failed to upload files: $e");
    }
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
        title: const Text("Upload New Challenge"),
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
          _showDocumentIdPopup2("Challenge Uploaded Successfully",
              "Challenge Uploaded Successfully");
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(color: Colors.orange),
          child: Center(
              child: Text(
            "Upload",
            style: TextStyle(color: Colors.white, fontSize: 18),
          )),
        ),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                          topRight: Radius.circular(10)),
                                    ),
                                    height: width * 0.10,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                            top: width * 0.02,
                                            left: width * 0.03,
                                            child: Text("Challenge Banner",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        Positioned(
                                            right: width * 0.03,
                                            top: width * 0.02,
                                            child: GestureDetector(
                                              onTap: () {
                                                _pickImageFromGallery();
                                              },
                                              child: Text("Edit",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            )),
                                      ],
                                    ),
                                  )),
                                  Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: width * 0.1),
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
                                          onTap: () {
                                            _pickImageFromCamera();
                                          },
                                          child: FaIcon(FontAwesomeIcons.camera,
                                              size: width * 0.06)))
                                ],
                              )),
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
                                          topRight: Radius.circular(10)),
                                    ),
                                    height: width * 0.10,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                            top: width * 0.02,
                                            left: width * 0.03,
                                            child: Text("Challenge Banner",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        Positioned(
                                            right: width * 0.03,
                                            top: width * 0.02,
                                            child: GestureDetector(
                                              onTap: () {
                                                _pickImageFromGallery();
                                              },
                                              child: Text("Edit",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            )),
                                      ],
                                    ),
                                  )),
                                  Positioned(
                                      top: width * 0.35,
                                      left: width * 0.33,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _pickImageFromGallery();
                                            },
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
                                      )),
                                  Positioned(
                                      bottom: width * 0.02,
                                      left: width * 0.02,
                                      child: GestureDetector(
                                          onTap: () {
                                            _pickImageFromCamera();
                                          },
                                          child: FaIcon(FontAwesomeIcons.camera,
                                              size: width * 0.06)))
                                ],
                              )),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: courseName,
                        decoration: const InputDecoration(
                          hintText: 'Enter Challenge Name',
                          labelText: 'Enter Challenge Name',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: workshopdescription,
                        decoration: const InputDecoration(
                          hintText: 'Enter Challenge Description',
                          labelText: 'Enter Challenge Description',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'From Date',
                              labelText: 'From Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selectDate(context,
                                fromDateController, (date) => _fromDate = date),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: toDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'To Date',
                              labelText: 'To Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selectDate(context, toDateController,
                                (date) => _toDate = date),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 10),
                        child: GestureDetector(
                          onTap: () {
                            final moduleName = TextEditingController();
                            final taskUptoController = TextEditingController();
                            DateTime? _taskUpto;

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Add Task'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: moduleName,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter Task Name',
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        controller: taskUptoController,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter Deadline',
                                          labelText: 'Deadline',
                                          suffixIcon:
                                              Icon(Icons.calendar_today),
                                        ),
                                        onTap: () => _selectDate(
                                          context,
                                          taskUptoController,
                                          (date) {
                                            _taskUpto = date;
                                          },
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
                                        modules[moduleName.text] = {
                                          'expanded': false,
                                          'content': [],
                                          'taskUpto': _taskUpto,
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
                              child: Text("Add Task"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: modules.isEmpty ? 40 : 300,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: modules.isEmpty
                          ? Center(
                              child: Text("No Tasks Yet"),
                            )
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
                                                    value: 'Opinions',
                                                    child: Text('Opinions'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: 'Quiz',
                                                    child: Text('Quiz'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: 'Poll',
                                                    child: Text('Poll'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: 'Form',
                                                    child: Text('Form'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: 'Note',
                                                    child: Text('Note'),
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
                                                children: [
                                                  if (modules[key]
                                                          ['taskUpto'] !=
                                                      null)
                                                    Text(
                                                      'Task Upto: ${modules[key]['taskUpto']}',
                                                      style: TextStyle(
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                  ...List<Widget>.from(
                                                    modules[key]['content'].map(
                                                        (contentType) => Text(
                                                            '• $contentType')),
                                                  ),
                                                ],
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
