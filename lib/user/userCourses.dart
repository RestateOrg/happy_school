// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/user/coursenames.dart';
import 'package:happy_school/user/search.dart';

class UserCourses extends StatefulWidget {
  const UserCourses({super.key});

  @override
  State<UserCourses> createState() => _UserCoursesState();
}

class _UserCoursesState extends State<UserCourses> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FocusNode _searchFocusNode = FocusNode();

  List _allCourses = [];
  List<Map<String, dynamic>> seachCourses = []; // Correct type
// This will hold the filtered courses for display
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> getCourseDetails(String courseName) async {
    try {
      // Reference to the course document
      final DocumentReference courseDocRef = _firestore
          .collection('Content')
          .doc('Content')
          .collection('Courses')
          .doc(courseName);

      // Fetch all module documents
      final QuerySnapshot modulesSnapshot =
          await courseDocRef.collection('Modules').get();

      // Fetch single info document (assuming only one exists)
      final QuerySnapshot infoSnapshot =
          await courseDocRef.collection('courseinfo').get();

      // Extract modules data including moduleName (doc ID)
      List<Map<String, dynamic>> modulesData = modulesSnapshot.docs.map((doc) {
        return {
          'moduleName': doc.id, // Adding moduleName as the doc ID
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      // Extract the single info data
      Map<String, dynamic>? infoData = infoSnapshot.docs.isNotEmpty
          ? infoSnapshot.docs.first.data() as Map<String, dynamic>
          : null;

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

  Future<List<String>> getUserCourses() async {
    List<String> usersCourses = [];
    try {
      // Get the currently authenticated user
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Handle the case where the user is not logged in
        return usersCourses; // Return empty list if user is not logged in
      }

      // Get the user's email
      final String email = user.email!;

      // Reference the Firestore document using the email
      final DocumentReference userInfoDocRef = _firestore
          .collection('Users')
          .doc(email)
          .collection('userinfo')
          .doc('userinfo');

      // Fetch the document containing user information
      final DocumentSnapshot userInfoSnapshot = await userInfoDocRef.get();

      // Check if the document exists and contains the 'courses' field
      if (userInfoSnapshot.exists && userInfoSnapshot.data() != null) {
        Map<String, dynamic> data =
            userInfoSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('courses')) {
          List<dynamic> courses = data['courses'] ?? [];

          // Add fetched courses to the usersCourses list
          usersCourses = courses.map((course) {
            return course.toString();
          }).toList();
        } else {
          print('No courses found in userinfo.');
        }
      } else {
        print('userinfo document does not exist.');
      }
    } catch (e) {
      print('Error: $e');
    }

    return usersCourses;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 200),
                    pageBuilder: (_, __, ___) => Search(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "What courses are you looking for?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "My Courses",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<String>>(
              future: getUserCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return SizedBox(
                    height: width * 2, // Set a fixed height for the list
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final courseName = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoursesScreen(
                                  courseName: courseName,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: width * 0.9,
                              height: width * 0.67,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: FutureBuilder<Map<String, dynamic>>(
                                future: getCourseDetails(courseName),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else if (snapshot.hasData) {
                                    final modules = snapshot.data!['modules']
                                        as List<Map<String, dynamic>>;
                                    final info = snapshot.data!['info']
                                        as Map<String, dynamic>;

                                    return Column(
                                      children: [
                                        Container(
                                          width: width * 0.9,
                                          height: width * 0.45,
                                          color: Colors.black12,
                                          child: CachedNetworkImage(
                                            imageUrl: info['courseImage'] ?? '',
                                            placeholder: (context, url) =>
                                                const Center(),
                                            key: UniqueKey(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: width * 0.9,
                                          height: width * 0.16,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 5),
                                                child: Text(
                                                  courseName,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 2),
                                                    child: Text(
                                                      modules.isEmpty
                                                          ? "No modules"
                                                          : "${modules.length} module${modules.length > 1 ? 's' : ''}",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      "2:30:44",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Center(
                                      child: Text('No module details found.'),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No courses found.'),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _search(String value) async {
    _allCourses.clear();
    if (value.isNotEmpty) {
      for (var item in _allCourses) {
        if (item['courseName']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase())) {
          seachCourses.add(item);
        }
      }
    } else {
      //await getSearchHistory();
    }
    setState(() {});
  }
}
