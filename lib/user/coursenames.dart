import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/user/moduleScreen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CoursesScreen extends StatelessWidget {
  final String courseName;

  CoursesScreen({Key? key, required this.courseName}) : super(key: key);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getCourseDetails() async {
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(courseName),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getCourseDetails(),
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ensure courseImage URL is valid and not empty
                  if (info.containsKey('courseImage') &&
                      info['courseImage'] != null &&
                      info['courseImage'].toString().isNotEmpty)
                    Container(
                      width: 500,
                      height: 250,
                      child: CachedNetworkImage(
                        imageUrl: info['courseImage'],
                        placeholder: (context, url) => Center(
                          child: const CircularProgressIndicator(),
                        ),
                        key: UniqueKey(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                        //fit: BoxFit.,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Image not available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  Padding(
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
                    padding: EdgeInsets.only(
                        top: 10, right: 15, bottom: 10, left: 10),
                    child: Text(
                      info['courseDescription'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.05, top: 20),
                    child: Text(
                      "Modules",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      final module = modules[index];

                      // Fix the vid field handling
                      String vid = module.containsKey('vid') &&
                              module['vid'] is String
                          ? YoutubePlayer.convertUrlToId(module['vid']) ?? ""
                          : "";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Modulescreen(
                                module: module,
                                vid: vid,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: Container(
                            width: width * 0.95,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(9, 0, 0, 0),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color.fromARGB(9, 0, 0, 0),
                                  width: 0.25,
                                )),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Module ${index + 1}: ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        module['moduleName'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: FaIcon(
                                          FontAwesomeIcons.chevronDown,
                                          color: Colors.orange,
                                          size: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 13.0),
                                        child: Text(
                                          modules.length.toString() +
                                              " Items  ",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ),
                                      Icon(Icons.circle,
                                          size: 5, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }

  String titleCase(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
