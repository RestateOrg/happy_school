import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happy_school/user/coursenames.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FocusNode _searchFocusNode = FocusNode();

  List _allCourses = [];
  List seachCourses = []; // Correct type
// This will hold the filtered courses for display
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getSearchCourses();
  }

  Future<Map<String, dynamic>> getCourseDetails(String courseName) async {
    try {
      // Reference to the course document
      final DocumentReference courseDocRef = _firestore
          .collection('Content')
          .doc('Content')
          .collection('Courses')
          .doc(courseName);

      final QuerySnapshot modulesSnapshot =
          await courseDocRef.collection('Modules').get();

      final QuerySnapshot infoSnapshot =
          await courseDocRef.collection('courseinfo').get();

      List<Map<String, dynamic>> modulesData = modulesSnapshot.docs.map((doc) {
        return {
          'moduleName': doc.id,
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

  Future<void> getSearchCourses() async {
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
          setState(() {
            _allCourses = courseNamesData.entries.map((entry) {
              return {
                'courseId': entry.key,
                'courseName': entry.value,
              };
            }).toList();

            print('Courses loaded: $_allCourses');
          });
        } else {
          print('No course names found');
          setState(() {
            _allCourses = [];
          });
        }
      } else {
        print('Course names document does not exist');
        setState(() {
          _allCourses = [];
        });
      }
    } catch (e) {
      print('Error fetching course names: $e');
      setState(() {
        _allCourses = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: CupertinoSearchTextField(
                focusNode: _searchFocusNode,
                placeholder: 'Search for a course',
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(30),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                onChanged: (value) async {
                  await _search(value);
                },
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: width * 2, // Set a fixed height for the list
            child: ListView.builder(
              itemCount: seachCourses.length,
              itemBuilder: (context, index) {
                final courseName = seachCourses[index]['courseName'];
                return Card(
                  child: GestureDetector(
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
                                    color: const Color.fromARGB(
                                        255, 181, 179, 179),
                                    child: CachedNetworkImage(
                                      imageUrl: info['courseImage'] ?? '',
                                      placeholder: (context, url) =>
                                          const Center(),
                                      key: UniqueKey(),
                                      errorWidget: (context, url, error) =>
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
                                          padding: EdgeInsets.only(top: 5),
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
                                              padding: EdgeInsets.only(top: 2),
                                              child: Text(
                                                modules.isEmpty
                                                    ? "No modules"
                                                    : "${modules.length} module${modules.length > 1 ? 's' : ''}",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 5),
                                              child: Text(
                                                "2:30:44",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
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
                  ),
                );
              },
            ),
          ),
        ));
  }

  Future<void> _search(String value) async {
    seachCourses.clear();
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
      //seachCourses = _allCourses;
    }
    setState(() {});
  }
}
