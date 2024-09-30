import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:happy_school/admin/Editcourse.dart';

class Coursesandworkshops extends StatefulWidget {
  const Coursesandworkshops({super.key});

  @override
  State<Coursesandworkshops> createState() => _CoursesandworkshopsState();
}

class _CoursesandworkshopsState extends State<Coursesandworkshops> {
  bool isCoursesSelected = true; // State variable to track selected option
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> challenges = [];
  bool isLoading = true; // State to track loading

  @override
  void initState() {
    super.initState();
    _fetchCoursesAndChallenges(); // Fetch data on initialization
  }

  Future<void> _delete_courses(String coursename, String uniqueCourseId) async {
    try {
      // Reference to the course document
      final courseRef = FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("Courses")
          .doc(coursename);

      // Get the course info document to delete the course image
      final courseInfoDoc =
          await courseRef.collection("courseinfo").doc("info").get();
      if (courseInfoDoc.exists) {
        final courseInfoData = courseInfoDoc.data();
        if (courseInfoData != null &&
            courseInfoData.containsKey("courseImage")) {
          final String courseImageUrl = courseInfoData["courseImage"];

          if (courseImageUrl
              .startsWith('https://firebasestorage.googleapis.com')) {
            // Delete the course image from Firebase Storage
            final Reference storageRef =
                FirebaseStorage.instance.refFromURL(courseImageUrl);
            await storageRef.delete();
            print("Course image deleted successfully from Firebase Storage");
          }
        }

        // Delete the course info document after deleting the image
        await courseRef.collection("courseinfo").doc("info").delete();
      }

      // Get the modules to delete related storage files
      final modulesSnapshot = await courseRef.collection("Modules").get();
      for (var moduleDoc in modulesSnapshot.docs) {
        final moduleData = moduleDoc.data();

        // Delete each file in the module from Firebase Storage
        moduleData.forEach((fileName, contentData) async {
          if (fileName != 's.no') {
            final String fileUrl = contentData['url'];
            if (fileUrl.startsWith('https://firebasestorage.googleapis.com')) {
              // Delete the file from Firebase Storage
              final Reference storageRef =
                  FirebaseStorage.instance.refFromURL(fileUrl);
              await storageRef.delete();
              print(
                  "File $fileName deleted successfully from Firebase Storage");
            }
          }
        });

        // Delete the module document from Firestore
        await moduleDoc.reference.delete();
      }

      // Finally, delete the course document itself
      await courseRef.delete();
      print("Course deleted successfully from Firestore");

      // Remove course name from courseNames document
      final courseNamesRef = FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("courseNames")
          .doc("courseNames");

      // Update the courseNames map by removing the course
      await courseNamesRef.update({
        uniqueCourseId: FieldValue.delete(),
      });
      print("Course name removed successfully from courseNames");

      // Update local state
      setState(() {
        courses.removeWhere((course) => course['courseName'] == coursename);
      });
    } catch (error) {
      print("Failed to delete course: $error");
    }
  }

  Future<void> _delete_challenge(
      String challengeName, String uniqueChallengeId) async {
    try {
      // Reference to the challenge document
      final challengeRef = FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("Challenges")
          .doc(challengeName);

      // Get the tasks to delete related storage files
      final tasksSnapshot = await challengeRef.collection("Tasks").get();
      for (var taskDoc in tasksSnapshot.docs) {
        final taskData = taskDoc.data();

        // Delete each file in the task from Firebase Storage
        for (var fileName in taskData.keys) {
          final fileData = taskData[fileName];

          if (fileData is String &&
              fileData.startsWith('https://firebasestorage.googleapis.com')) {
            // If it's a file URL, delete it from Firebase Storage
            final Reference storageRef =
                FirebaseStorage.instance.refFromURL(fileData);
            await storageRef.delete();
          }
        }

        // Delete the task document from Firestore
        await taskDoc.reference.delete();
      }

      // Delete challenge info and tasks subcollection
      await challengeRef.collection("challengeinfo").doc("info").delete();

      // Finally, delete the challenge document itself
      await challengeRef.delete();
      print("Challenge deleted successfully from Firestore");

      // Remove challenge name from ChallengeNames document
      final challengeNamesRef = FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("ChallengeNames")
          .doc("ChallengeNames");

      // Update the ChallengeNames map by removing the challenge
      await challengeNamesRef.update({
        uniqueChallengeId: FieldValue.delete(),
      });
      print("Challenge name removed successfully from ChallengeNames");

      // Optional: Update local state if you're keeping track of challenges locally
      setState(() {
        challenges.removeWhere(
            (challenge) => challenge['ChallengeName'] == challengeName);
      });
    } catch (error) {
      print("Failed to delete challenge: $error");
    }
  }

  Future<void> _fetchCoursesAndChallenges() async {
    try {
      // Fetch course names from the courseNames collection
      final courseNamesSnapshot = await FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("courseNames")
          .doc("courseNames")
          .get();

      // Extract course names
      final courseNamesData = courseNamesSnapshot.data() ?? {};
      List<String> courseNames = courseNamesData.values.cast<String>().toList();

      // Fetch the actual course data based on course names
      List<Map<String, dynamic>> fetchedCourses = [];
      for (String courseName in courseNames) {
        final courseDoc = await FirebaseFirestore.instance
            .collection("Content")
            .doc("Content")
            .collection("Courses")
            .doc(courseName)
            .collection("courseinfo")
            .doc("info")
            .get();
        fetchedCourses.add(courseDoc.data() as Map<String, dynamic>);
      }

      // Fetch challenge names
      final challengeNamesSnapshot = await FirebaseFirestore.instance
          .collection("Content")
          .doc("Content")
          .collection("ChallengeNames")
          .doc("ChallengeNames")
          .get();

      // Extract challenge names
      final challengeNamesData = challengeNamesSnapshot.data() ?? {};
      List<String> challengeNames =
          challengeNamesData.values.cast<String>().toList();

      // Fetch the actual challenge data based on challenge names
      List<Map<String, dynamic>> fetchedChallenges = [];
      for (String challengeName in challengeNames) {
        final challengeDoc = await FirebaseFirestore.instance
            .collection("Content")
            .doc("Content")
            .collection("Challenges")
            .doc(challengeName)
            .collection("challengeinfo")
            .doc("info")
            .get();
        fetchedChallenges.add(challengeDoc.data() as Map<String, dynamic>);
      }

      setState(() {
        courses = fetchedCourses;
        challenges =
            fetchedChallenges; // Add this line to store fetched challenges
        isLoading = false;
      });
    } catch (e) {
      print("Failed to fetch data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header with Courses and Challenges buttons
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isCoursesSelected = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isCoursesSelected
                                  ? Colors.orange[400]
                                  : Colors.grey[200],
                              border: Border.all(
                                color: isCoursesSelected
                                    ? (Colors.orange[400] ?? Colors.orange)
                                    : (Colors.grey[200] ?? Colors.grey),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Courses',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isCoursesSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isCoursesSelected = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: !isCoursesSelected
                                  ? Colors.orange[400]
                                  : Colors.grey[200],
                              border: Border.all(
                                color: !isCoursesSelected
                                    ? (Colors.orange[400] ?? Colors.orange)
                                    : (Colors.grey[200] ?? Colors.grey),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Challenges',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: !isCoursesSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Conditionally show content based on selection
                  isCoursesSelected
                      ? _buildCourseList() // Show courses
                      : _buildChallengeList(), // Show challenges
                ],
              ),
            ),
    );
  }

  // Build the list of courses
  Widget _buildCourseList() {
    if (courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No courses available', style: TextStyle(fontSize: 18)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.white,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      color: Colors.black.withOpacity(0.2), // Black background
                      height: 200.0,
                      width: double.infinity,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: course['courseImage'] ?? '',
                        placeholder: (context, url) =>
                            Center(child: const CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        height: 200.0,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['courseName'] ?? 'Unknown Course',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        course['courseDescription'] ?? 'No Description',
                        style: const TextStyle(fontSize: 14.0),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Edit and Delete buttons
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black54),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCoursePage(
                                courseName: course['courseName'],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () {
                          _delete_courses(
                              course['courseName'], course['courseId']);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build the list of challenges
  Widget _buildChallengeList() {
    if (challenges.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No challenges available', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.white,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      color: Colors.black.withOpacity(0.2), // Black background
                      height: 200.0,
                      width: double.infinity,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: challenge['ChallengeImage'] ?? '',
                        placeholder: (context, url) =>
                            Center(child: const CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        height: 200.0,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge['ChallengeName'] ?? 'Unknown Course',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        challenge['ChallengeDescription'] ?? 'No Description',
                        style: const TextStyle(fontSize: 14.0),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Edit and Delete buttons
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black54),
                        onPressed: () {
                          // Add your edit logic here
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () {
                          _delete_challenge(challenge['ChallengeName'],
                              challenge['ChallengeId']);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
