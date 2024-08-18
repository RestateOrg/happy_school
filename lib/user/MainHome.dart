import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Mainhome extends StatefulWidget {
  const Mainhome({super.key});

  @override
  State<Mainhome> createState() => _MainhomeState();
}

class _MainhomeState extends State<Mainhome> {
  final FocusNode _searchFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getCourses() async {
    List<Map<String, dynamic>> allCourses = [];

    try {
      QuerySnapshot subcollectionsSnapshot =
          await _firestore.collection('course').get();
      print('Subcollections snapshot: ${subcollectionsSnapshot.docs.length}');

      for (QueryDocumentSnapshot subcollectionDoc
          in subcollectionsSnapshot.docs) {
        String courseName = subcollectionDoc.id;
        print(courseName);

        allCourses.add({
          'courseName': courseName,
        });
      }
      print(allCourses.length);
      return allCourses;
    } catch (e) {
      print("Error fetching courses: $e");
      return [];
    }
  }

  Widget _courseItems(Map<String, dynamic> course) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 150,
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
        child: Center(
          child: Text(
            course['courseName'].toString(), // Display the course name
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
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
                          )
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
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            // Handle course item tap here
                          },
                          child: _courseItems(snapshot.data![index]),
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
