import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/user/coursenames.dart';

class Mainhome extends StatefulWidget {
  const Mainhome({super.key});

  @override
  State<Mainhome> createState() => _MainhomeState();
}

class _MainhomeState extends State<Mainhome> {
  final FocusNode _searchFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Modified function to return a Future<List<String>> instead of void
  Future<List<String>> getCourseDetailsInfo(String courseName) async {
    try {
      final DocumentReference courseDocRef = _firestore
          .collection('Content')
          .doc('Content')
          .collection('Courses')
          .doc(courseName);

      final QuerySnapshot infoSnapshot =
          await courseDocRef.collection('courseinfo').get();

      // Extract and return course info data
      if (infoSnapshot.docs.isNotEmpty) {
        return infoSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['courseImage']?.toString() ?? ''; // Ensure it's a String
        }).toList();
      } else {
        print('No course info found');
        return [];
      }
    } catch (e) {
      print('Error fetching course details: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final DocumentReference courseNamesRef = _firestore
          .collection('Content')
          .doc('Content')
          .collection('courseNames')
          .doc('courseNames');

      final DocumentSnapshot courseNamesDoc = await courseNamesRef.get();

      if (courseNamesDoc.exists) {
        final Map<String, dynamic>? courseNamesData =
            courseNamesDoc.data() as Map<String, dynamic>?;

        if (courseNamesData != null && courseNamesData.isNotEmpty) {
          return courseNamesData.entries.map((entry) {
            return {
              'courseId': entry.key,
              'courseName': entry.value,
            };
          }).toList();
        } else {
          print('No course names found');
          return [];
        }
      } else {
        print('Course names document does not exist');
        return [];
      }
    } catch (e) {
      print('Error fetching course names: $e');
      return [];
    }
  }

  Widget _courseItems(Map<String, dynamic> course, String courseImage) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 200,
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
        child: Column(
          children: [
            Container(
              width: 200,
              height: 90,
              child: courseImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: courseImage,
                      placeholder: (context, url) => Center(
                        child: const CircularProgressIndicator(),
                      ),
                      key: UniqueKey(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )
                  : Center(child: Text(course['courseName'])),
            ),
            Container(
              width: 200,
              height: 26,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      course['courseName'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        // Your enroll action code here
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10), // Adjusted padding
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orangeAccent),
                          color: Colors.orange,
                        ),
                        child: Text(
                          'Enroll',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: CupertinoSearchTextField(
                  placeholder: "What course are you looking for?",
                  focusNode: _searchFocusNode,
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
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, left: 7),
              child: Container(
                height: 80,
                width: width * 0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                      child: FaIcon(
                        FontAwesomeIcons.medal,
                        color: Colors.grey,
                        size: 35,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Silver",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("1000 more coins for the Gold"),
                          Row(
                            children: [
                              Container(
                                width: 150,
                                height: 5,
                                color: Colors.orangeAccent,
                              ),
                              Container(
                                width: 60,
                                height: 5,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 15,
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
            Container(
              width: width,
              height: width * 0.7,
              child: Image.asset(
                "assets/Images/sample.png",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Courses",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getCourses(),
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
                  return Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<List<String>>(
                          future: getCourseDetailsInfo(
                              snapshot.data![index]['courseName']),
                          builder: (context, courseInfoSnapshot) {
                            if (courseInfoSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (courseInfoSnapshot.hasError) {
                              return Center(
                                child:
                                    Text('Error: ${courseInfoSnapshot.error}'),
                              );
                            } else if (courseInfoSnapshot.hasData) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CoursesScreen(
                                        courseName: snapshot.data![index]
                                                ['courseName']
                                            .toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: _courseItems(
                                  snapshot.data![index],
                                  courseInfoSnapshot.data!.isNotEmpty
                                      ? courseInfoSnapshot.data![0]
                                      : '', // Use the first image as a sample
                                ),
                              );
                            } else {
                              return const Center(
                                child: Text('No course info available.'),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No course found.'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
