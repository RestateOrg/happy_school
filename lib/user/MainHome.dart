// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/user/Enroll.dart';
import 'package:happy_school/user/coursenames.dart';
import 'package:happy_school/user/showChallenges.dart';
import 'package:happy_school/utils/hexcolor.dart';

class Mainhome extends StatefulWidget {
  const Mainhome({super.key});

  @override
  State<Mainhome> createState() => _MainhomeState();
}

class _MainhomeState extends State<Mainhome> {
  AddCourse ac = AddCourse();

  late PageController _pageController;
  late int currentIndex = 0;
  late Timer timer;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> usersCourses = []; // List to store the course names

  @override
  void initState() {
    super.initState();
    getUserCourses(); // Call the function to fetch and store courses
    getChallanges();
    _pageController = PageController();
  }

  @override
  void dispose() {
    // Dispose the PageController to prevent memory leaks
    _pageController.dispose();
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

  // ignore: non_constant_identifier_names

  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      // Reference to the 'announcements' collection
      final CollectionReference announcementsRef =
          _firestore.collection('announcements');

      // Fetch all documents from the 'announcements' collection
      final QuerySnapshot announcementsSnapshot = await announcementsRef.get();

      // Check if there are any documents in the snapshot
      if (announcementsSnapshot.docs.isNotEmpty) {
        // Extract the data from each document and return it as a list of maps
        return announcementsSnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      } else {
        print('No announcements found');
        return [];
      }
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

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
          return data['courseImage']?.toString() ?? '';
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

  Future<List<Map<String, dynamic>>> getChallanges() async {
    try {
      final DocumentReference courseNamesRef = _firestore
          .collection('Content')
          .doc('Content')
          .collection('ChallengeNames')
          .doc('ChallengeNames');

      final DocumentSnapshot courseNamesDoc = await courseNamesRef.get();

      if (courseNamesDoc.exists) {
        final Map<String, dynamic>? courseNamesData =
            courseNamesDoc.data() as Map<String, dynamic>?;

        if (courseNamesData != null && courseNamesData.isNotEmpty) {
          return courseNamesData.entries.map((entry) {
            return {
              'challangeId': entry.key,
              'challangeName': entry.value,
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

  Future<Map<String, dynamic>> getChallengesInfo(String challengeName) async {
    try {
      final DocumentReference challengeDocRef = _firestore
          .collection('Content')
          .doc('Content')
          .collection('Challenges')
          .doc(challengeName);

      // Fetching challenge info
      final QuerySnapshot infoSnapshot =
          await challengeDocRef.collection('challengeinfo').get();

      // Fetching tasks
      final QuerySnapshot tasksSnapshot =
          await challengeDocRef.collection('Tasks').get();

      // Extract challenge info
      List<Map<String, dynamic>> challengeInfo = [];
      if (infoSnapshot.docs.isNotEmpty) {
        challengeInfo = infoSnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      }

      // Extract tasks info and add taskName (doc ID)
      List<Map<String, dynamic>> tasksInfo = [];
      if (tasksSnapshot.docs.isNotEmpty) {
        tasksInfo = tasksSnapshot.docs.map((doc) {
          final taskData = doc.data() as Map<String, dynamic>;
          return {
            'taskName': doc.id, // Use doc.id as the taskName
            ...taskData, // Add the rest of the task data
          };
        }).toList();
      }

      // Return a single map containing both challenge info and tasks
      return {
        'challengeInfo': challengeInfo,
        'tasks': tasksInfo,
      };
    } catch (e) {
      print('Error fetching challenge details: $e');
      return {
        'challengeInfo': [],
        'tasks': [],
      };
    }
  }

  Widget _UpcommingChallanges(
    List<Map<String, dynamic>> challengeInfo,
    List<Map<String, dynamic>> tasks,
  ) {
    String timeLeftText = '';
    if (tasks.isNotEmpty && tasks[0]['taskUpto'] != null) {
      // Parse the deadline
      DateTime deadline = DateTime.parse(tasks[0]['taskUpto']);
      DateTime now = DateTime.now();

      // Calculate the difference between now and the deadline
      Duration difference = deadline.difference(now);

      // Get the remaining days, hours, and minutes
      int daysLeft = difference.inDays;
      int hoursLeft =
          difference.inHours.remainder(24); // Remainder for hours after days
      int minutesLeft = difference.inMinutes
          .remainder(60); // Remainder for minutes after hours

      // Conditionally include days in the string if daysLeft is greater than 0
      if (daysLeft > 0) {
        timeLeftText =
            '$daysLeft days, $hoursLeft hours, $minutesLeft minutes left';
      } else {
        timeLeftText = '$hoursLeft hours, $minutesLeft minutes left';
      }
    } else {
      timeLeftText = 'No deadline set';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(9.0),
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
              color: Colors.black12,
              child: challengeInfo[0]['ChallengeImage'].isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: challengeInfo[0]['ChallengeImage'],
                      placeholder: (context, url) => Center(),
                      key: UniqueKey(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )
                  : Center(child: Text(challengeInfo[0]['ChallengeName'])),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        challengeInfo[0]['ChallengeName'],
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
                        onTap: () async {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10), // Adjusted padding
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: HexColor("#FF6B00"),
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
                Text(
                  timeLeftText,
                  style: TextStyle(fontSize: 10),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseItems(Map<String, dynamic> course, String courseImage) {
    String courseName = course['courseName'];
    bool isEnrolled =
        usersCourses.contains(courseName.toLowerCase().replaceAll(" ", ''));
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
              color: Colors.black12,
              child: courseImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: courseImage,
                      placeholder: (context, url) => Center(),
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
                        await ac
                            .saveCourseToUserCollection(course['courseName']);
                        setState(() {
                          getUserCourses();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10), // Adjusted padding
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: HexColor("#FF6B00"),
                        ),
                        child: Text(
                          (isEnrolled) ? "Enrolled" : 'Enroll',
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
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Text(
                "Announcements",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getAnnouncements(), // Call your getAnnouncements function
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // PageController for PageView
                  final PageController _pageController = PageController();
                  int currentIndex = 0;

                  return Column(
                    children: [
                      // PageView for showing announcements
                      Container(
                        height: 200, // Adjust height as needed
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: snapshot.data!.length,
                          onPageChanged: (value) {
                            currentIndex = value; // Track current page index
                          },
                          itemBuilder: (context, index) {
                            final announcementData = snapshot.data![index];
                            return Card(
                              color: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CachedNetworkImage(
                                    key: UniqueKey(),
                                    imageUrl: announcementData[
                                        'imageUrl'], // Assuming 'img' holds the image URL
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    height: 150, // Set the height for the image
                                    width: double.infinity,
                                    //fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      announcementData['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Dots for indicating the current page
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                            snapshot.data!.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: currentIndex == index
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                      child: Text('No announcements available'));
                }
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Upcomming Challanges",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getChallanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<Map<String, dynamic>>(
                          future: getChallengesInfo(
                              snapshot.data![index]['challangeName']),
                          builder: (context, courseInfoSnapshot) {
                            if (courseInfoSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center();
                            } else if (courseInfoSnapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Error: ${courseInfoSnapshot.error}'));
                            } else if (courseInfoSnapshot.hasData) {
                              // Extract challengeInfo and tasks from the data
                              final challengeInfo =
                                  courseInfoSnapshot.data!['challengeInfo'];
                              final tasks = courseInfoSnapshot.data!['tasks'];

                              // Pass the combined challengeInfo and tasks map to the widget
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Showchallenges(
                                            challengeInfo: challengeInfo,
                                            tasks: tasks)),
                                  );
                                },
                                child: _UpcommingChallanges(
                                  challengeInfo, // Pass the challenge info
                                  tasks, // Pass the tasks
                                ),
                              );
                            } else {
                              return const Center(
                                  child: Text('No challenge info available.'));
                            }
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: Text('No course found.'));
                }
              },
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
                              return const Center();
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
