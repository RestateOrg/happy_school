// ignore_for_file: prefer_interpolation_to_compose_strings, sized_box_for_whitespace, library_private_types_in_public_api, use_super_parameters

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/user/Enroll.dart';
import 'package:happy_school/user/moduleScreen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CoursesScreen extends StatefulWidget {
  final String courseName;

  // ignore: prefer_const_constructors_in_immutables
  CoursesScreen({Key? key, required this.courseName}) : super(key: key);

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isExpanded = false;
  TextEditingController review = TextEditingController();

  AddCourse ac = AddCourse();

  final List<String> usersCourses = []; // List to store the course names
  final List<dynamic> Cinfo = [];

  @override
  void initState() {
    super.initState();
    getUserCourses(); // Call the function to fetch and store courses
  }

  @override
  void dispose() {
    review.dispose();
    super.dispose();
  }

  // Fetch and store the course names in usersCourses list
  Future<void> getUserCourses() async {
    try {
      // Get the currently authenticated user
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Handle the case where the user is not logged in
        return;
      }

      // Get the user's email
      final String email = user.email!;

      // Reference the Firestore document using the email
      final DocumentReference courseDocRef =
          _firestore.collection('Users').doc(email);

      // Fetch course names
      final QuerySnapshot infoSnapshot =
          await courseDocRef.collection('courseNames').get();

      // Check if there are any documents
      if (infoSnapshot.docs.isNotEmpty) {
        // Clear the list to avoid duplications
        setState(() {
          usersCourses.clear();
          // Add fetched courses to the usersCourses list
          usersCourses.addAll(
            infoSnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return data['courseName']
                      ?.toString()
                      .toLowerCase()
                      .replaceAll(" ", "") ??
                  '';
            }).toList(),
          );
        });
      } else {
        print('No courses found for this user.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Define Cinfo as a mutable list

  Future<Map<String, dynamic>> getCourseDetails(String courseName) async {
    try {
      final DocumentReference courseDocRef = _firestore
          .collection('Content')
          .doc('Content')
          .collection('Courses')
          .doc(courseName);

      // Fetching modules and course info
      final QuerySnapshot modulesSnapshot =
          await courseDocRef.collection('Modules').get();
      final QuerySnapshot infoSnapshot =
          await courseDocRef.collection('courseinfo').get();

      // Extract and sort module data
      List<Map<String, dynamic>> modulesData = modulesSnapshot.docs.map((doc) {
        return {
          'moduleName': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      modulesData.sort((a, b) {
        return (a['s.no'] as int).compareTo(b['s.no'] as int);
      });

      // Extract course info (ensure it's not null)
      Map<String, dynamic>? infoData = infoSnapshot.docs.isNotEmpty
          ? infoSnapshot.docs.first.data() as Map<String, dynamic>
          : null;

      // Store 'faqs' data into Cinfo list
      if (infoData != null && infoData.containsKey('faqs')) {
        Cinfo.clear(); // Clear the previous data in Cinfo
        Cinfo.addAll(infoData['faqs'] as List<dynamic>);
      }

      // Return both modules and info
      return {
        'modules': modulesData,
        'info': infoData ?? {},
      };
    } catch (e) {
      print('Error fetching course details: $e');
      return {
        'modules': [],
        'info': {},
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    String c = widget.courseName;
    bool isEnrolled =
        usersCourses.contains(c.toLowerCase().replaceAll(" ", ''));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.courseName),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          await ac.saveCourseToUserCollection(c);
          setState(() {
            getUserCourses();
          });
        },
        child: Container(
          height: 60,
          decoration: const BoxDecoration(color: Colors.orange),
          child: Center(
            child: Text(
              (isEnrolled) ? "Enrolled" : 'Enroll',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: getCourseDetails(widget.courseName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final modules =
                      snapshot.data!['modules'] as List<Map<String, dynamic>>;
                  final info = snapshot.data!['info'] as Map<String, dynamic>;
                  String courseDis = info['courseDescription'] ?? "";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (info.containsKey('courseImage') &&
                          info['courseImage'] != null &&
                          info['courseImage'].toString().isNotEmpty)
                        Container(
                          width: 500,
                          height: 250,
                          child: CachedNetworkImage(
                            imageUrl: info['courseImage'],
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            key: UniqueKey(),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Image not available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 10),
                        child: Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, right: 15, bottom: 10, left: 10),
                        child: RichText(
                          text: TextSpan(
                            text: isExpanded
                                ? courseDis
                                : courseDis.length > 500
                                    ? courseDis.substring(0, 500) + ' '
                                    : courseDis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                            children: courseDis.length > 500
                                ? [
                                    TextSpan(
                                      text: isExpanded ? ' less' : 'more...',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            isExpanded = !isExpanded;
                                          });
                                        },
                                    ),
                                  ]
                                : [],
                          ),
                          textAlign: TextAlign.justify,
                          softWrap: true,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.05, top: 20),
                        child: const Text(
                          "Modules",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                                          ),
                                        ),
                                        Expanded(
                                          flex: 8,
                                          child: Text(
                                            module['moduleName'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        if (module['pdf'] != null &&
                                            module['pdf']['url'] != null)
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  FontAwesomeIcons.filePdf,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    module['pdf']['url'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (module['ppt'] != null &&
                                            module['ppt']['url'] != null)
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  FontAwesomeIcons
                                                      .filePowerpoint,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    module['ppt']['url'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text('No data found.'));
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Text(
                'Write a review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orangeAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: review,
                decoration: const InputDecoration(
                  hintText: 'Write your review',
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
