import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Adminhome extends StatefulWidget {
  const Adminhome({super.key});

  @override
  State<Adminhome> createState() => _AdminhomeState();
}

class _AdminhomeState extends State<Adminhome> {
  Map<String, dynamic> modules = {};
  TextEditingController courseName = TextEditingController();

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

  Future<void> UploadtoFirebase() async {
    final coursename = courseName.text.trim();

    // Validate the course name
    if (coursename.isEmpty) {
      print("Course name cannot be empty.");
      return;
    }

    final modulesCollection = FirebaseFirestore.instance.collection(coursename);

    try {
      for (var module in modules.entries) {
        final moduleName = module.key;
        final moduleData = module.value;
        final moduleContent = moduleData['content'];

        for (var content in moduleContent) {
          final fileName = content['fileName'];

          if (content.containsKey('type') && content['type'] == 'video') {
            // Handle video content with YouTube URL
            final youtubeUrl = content['youtubeUrl'];

            // Create a document in Firestore with video details
            final documentData = {
              fileName.toString(): youtubeUrl,
            };
            await modulesCollection
                .doc(moduleName)
                .set(documentData, SetOptions(merge: true));
          } else {
            // Handle other types of files
            final file = content['file'];

            // Extract the file extension from the path
            final fileExtension = file.path.split('.').last;
            final fullFileName = '$fileName.$fileExtension';

            // Upload file to Firebase Storage with correct extension
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('$moduleName/$fullFileName');
            await storageRef.putFile(file);

            // Get the download URL of the uploaded file
            final downloadURL = await storageRef.getDownloadURL();

            // Create a document in Firestore with the file details
            final documentData = {
              fileName.toString(): downloadURL,
            };
            await modulesCollection
                .doc(moduleName)
                .set(documentData, SetOptions(merge: true));
          }
        }
      }

      print("Files uploaded successfully.");
    } catch (e) {
      print("Failed to upload files: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Upload New Course"),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          UploadtoFirebase();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ListView(
                children: modules.keys.map((String key) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        modules[key]['expanded'] = !modules[key]['expanded'];
                      });
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  itemBuilder: (BuildContext context) =>
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
                                  padding: const EdgeInsets.only(left: 8.0),
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
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List<Widget>.from(
                                    modules[key]['content'].map((contentType) =>
                                        Text('• $contentType')),
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
        ],
      ),
    );
  }
}
