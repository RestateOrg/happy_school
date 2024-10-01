// ignore_for_file: prefer_interpolation_to_compose_strings, sized_box_for_whitespace, library_private_types_in_public_api, use_super_parameters

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/admin/Profile.dart';
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
  final User? user = FirebaseAuth.instance.currentUser;
  bool isExpanded = false;
  bool isFaqExpanded = false;
  TextEditingController reviewController = TextEditingController();
  double rating = 0.0; // Initial rating value
  AddCourse ac = AddCourse();

  final List<String> usersCourses = []; // List to store the course names
  final List<dynamic> Cinfo = [];
  List<String> rList = [];
  String? email;
  bool showAllModules = false;
  bool isMExpanded = false;
  @override
  void initState() {
    super.initState();
    getUserCourses(); // Call the function to fetch and store courses
    //getCourseDetails(widgit.courseName);
    populateRList(widget.courseName);
  }

  @override
  void dispose() {
    reviewController.dispose();
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
      setState(() {
        email = user.email!;
      });

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

  Future<void> populateRList(String courseName) async {
    try {
      // Reference to the reviews collection of the specific course
      final CollectionReference reviewsCollection = _firestore
          .collection('Content')
          .doc('Content')
          .collection('Courses')
          .doc(courseName)
          .collection('reviews');

      // Fetch all documents from the 'reviews' collection
      QuerySnapshot reviewsSnapshot = await reviewsCollection.get();

      // Check if the collection has documents
      if (reviewsSnapshot.docs.isNotEmpty) {
        setState(() {
          // Populate rList with the 'email' field from each document
          rList = reviewsSnapshot.docs
              .map((doc) => doc['email'] as String)
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching review data: $e');
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

      // Extract and sort modules by 'module s.no'
      List<Map<String, dynamic>> modulesData = modulesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Sort fields inside the module by their 's.no'
        final sortedFields =
            data.entries.where((entry) => entry.value is Map).map((entry) {
          final fieldData = entry.value as Map<String, dynamic>;
          return {
            'fieldName': entry.key,
            's.no': fieldData['s.no'] ?? 0,
            'url': fieldData['url'] ?? ''
          };
        }).toList();

        sortedFields
            .sort((a, b) => (a['s.no'] as int).compareTo(b['s.no'] as int));

        return {
          'moduleName': doc.id,
          'moduleSno': data['s.no'] ?? 0, // Module 's.no'
          'fields': sortedFields // Sorted fields inside the module
        };
      }).toList();

      // Sort the modules by 'module s.no'
      modulesData.sort(
          (a, b) => (a['moduleSno'] as int).compareTo(b['moduleSno'] as int));

      // Extract course info (ensure it's not null)
      Map<String, dynamic>? infoData = infoSnapshot.docs.isNotEmpty
          ? infoSnapshot.docs.first.data() as Map<String, dynamic>
          : null;

      // Store 'faqs' data into Cinfo list
      if (infoData != null && infoData.containsKey('faqs')) {
        Cinfo.clear(); // Clear previous data in Cinfo
        Cinfo.addAll(infoData['faqs'] as List<dynamic>);
      }

      // Now fetch the review field to extract the emails
      DocumentSnapshot reviewDoc =
          await courseDocRef.collection('courseinfo').doc('info').get();

      // Check if the review document exists
      if (reviewDoc.exists && reviewDoc.data() != null) {
        Map<String, dynamic> reviewData =
            reviewDoc.data() as Map<String, dynamic>;

        // Check if the 'review' field exists
        if (reviewData.containsKey('review')) {
          Map<String, dynamic> reviewMap =
              reviewData['review'] as Map<String, dynamic>;
          rList = reviewMap.keys.toList(); // Store email keys in rList
        }
      }

      // Return both modules and course info (without emails)
      return {
        'modules': modulesData,
        'info': infoData ?? {},
      };
    } catch (e) {
      print('Error fetching course details and reviews: $e');
      return {
        'modules': [],
        'info': {},
      };
    }
  }

  Future<Map<String, dynamic>> getReviews(String courseName) async {
    try {
      // Reference to the reviews collection of the specific course
      CollectionReference reviewCollection = _firestore
          .collection('Content')
          .doc('Content')
          .collection('Courses')
          .doc(courseName)
          .collection('reviews');

      // Fetch all reviews for this course
      QuerySnapshot reviewSnapshot = await reviewCollection.get();

      // Initialize a map to hold the reviews
      Map<String, dynamic> reviewMap = {};

      // Loop through the review documents and add them to the reviewMap
      for (var doc in reviewSnapshot.docs) {
        if (doc.exists && doc.data() != null) {
          reviewMap[doc['email']] = {
            'review': doc['review'],
            'rating': doc['rating'],
          };
        }
      }

      return reviewMap; // Return the map containing all reviews
    } catch (e) {
      print('Error fetching reviews: $e');
      throw Exception('Failed to fetch reviews.');
    }
  }

  Future<void> postReview(String reviewText, double rating) async {
    if (user != null && reviewText.isNotEmpty) {
      try {
        final String email = user!.email!;

        // Reference to the reviews collection of the specific course
        CollectionReference reviewCollection = _firestore
            .collection('Content')
            .doc('Content')
            .collection('Courses')
            .doc(widget.courseName)
            .collection('reviews');

        // Save the review with email, reviewText, and rating
        await reviewCollection.doc(email).set({
          'email': email,
          'review': reviewText,
          'rating': rating, // Save the rating
        });

        // Clear the text field after submission
        reviewController.clear();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review posted successfully!')),
        );
      } catch (e) {
        print('Error posting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error posting review.')),
        );
      }
    }
  }

  Widget _writeReviewSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Text(
            'Write a review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            controller: reviewController,
            decoration: const InputDecoration(
              hintText: 'Write your review',
              border: InputBorder.none,
            ),
            maxLines: 2,
          ),
        ),
        RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4),
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.orange,
          ),
          onRatingUpdate: (newRating) {
            setState(() {
              rating = newRating; // Update rating when the user taps on stars
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              // Handle posting the review, pass both review text and rating
              postReview(reviewController.text, rating);
            },
            child: const Text('Post Review'),
          ),
        ),
      ],
    );
  }

  Widget _Faqs(List<Map<String, dynamic>> userFaqs, int displayedFaqsCount) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(
        // left: width * 0.05,
        top: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: width * 0.05),
            child: const Text(
              "FAQS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedFaqsCount,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.white,
                child: ExpansionTile(
                  title: Text(
                    'Q: ' + userFaqs[index]['question'] ?? ' ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  iconColor: Colors.orange,
                  collapsedIconColor: Colors.orange,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'A: ' + userFaqs[index]['answer'] ?? '',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _review(List<Map<String, dynamic>> userReview) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // const SizedBox(height: 10), // Add some spacing
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Expanded(
              child: ListView.builder(
                shrinkWrap: true, // Constrain the size
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userReview.length,
                itemBuilder: (context, index) {
                  final review = userReview[index];
                  return Card(
                    child: Container(
                      width: width * 0.5,
                      height: 100,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black, // Background color
                                    shape: BoxShape.circle, // Circular shape
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review['email'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 13,
                                            ),
                                            Text(
                                              review['rating'].toString(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )),
                              ],
                            ),
                            Text(review['review'])
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModules(Map<String, dynamic> module, String vid, int index) {
    final width = MediaQuery.of(context).size.width;
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
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Container(
          width: width * 0.95,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(9, 0, 0, 0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(9, 0, 0, 0),
              width: 0.25,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Module " + (index + 1).toString() + ":",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
                  if (module['pdf'] != null && module['pdf']['url'] != null)
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (module['ppt'] != null && module['ppt']['url'] != null)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.filePowerpoint,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              module['ppt']['url'],
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getCourseDetails(widget.courseName);

    print(rList);
    final width = MediaQuery.of(context).size.width;
    String c = widget.courseName;
    bool isEnrolled =
        usersCourses.contains(c.toLowerCase().replaceAll(" ", ''));
    bool reviwed = rList.contains(email);
    print(reviwed);
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: isMExpanded
                            ? modules.length
                            : 2, // Show only one module initially
                        itemBuilder: (context, index) {
                          final module = modules[index];
                          String vid = module.containsKey('vid') &&
                                  module['vid']['url'] is String
                              ? YoutubePlayer.convertUrlToId(
                                      module['vid']['url']) ??
                                  ""
                              : "";

                          return _buildModules(module, vid, index);
                        },
                      ),
                      if (modules.length > 2)
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isMExpanded =
                                    !isMExpanded; // Toggle between expanded/collapsed
                              });
                            },
                            child: Container(
                              width: width * 0.94,
                              height: width * 0.15,
                              decoration: BoxDecoration(
                                // color: Colors.amber,
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners
                                border: Border.all(
                                    color: Colors.black,
                                    width: 1), // Black border
                              ),
                              child: Center(
                                child: Text(
                                  isMExpanded
                                      ? 'Show less modules'
                                      : 'Show more modules',
                                  style: const TextStyle(
                                    color: Colors
                                        .black, // Adjust text color if needed
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return const Center(child: Text('No data found.'));
                }
              },
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: getCourseDetails(widget.courseName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('');
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final info = snapshot.data!['info'] as Map<String, dynamic>;

                  // Extract FAQ details if present
                  List<Map<String, dynamic>> userFaqs = [];
                  if (info.containsKey('faqs') && info['faqs'] != null) {
                    userFaqs = List<Map<String, dynamic>>.from(
                      (info['faqs'] as List<dynamic>).map((faq) => {
                            'question':
                                faq['question'] ?? 'No question available',
                            'answer': faq['answer'] ?? 'No answer available',
                          }),
                    );
                  }

                  // Determine number of FAQs to show based on the toggle state
                  final displayedFaqsCount =
                      isFaqExpanded ? userFaqs.length : 2;

                  return Column(
                    children: [
                      // Return the FAQ widget with the userFaqs list
                      _Faqs(userFaqs, displayedFaqsCount),

                      // Show toggle button if FAQs are more than 3
                      if (userFaqs.length > 2)
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isFaqExpanded =
                                    !isFaqExpanded; // Toggle between expanded/collapsed
                              });
                            },
                            child: Container(
                              width: width * 0.93,
                              height: width * 0.15,
                              decoration: BoxDecoration(
                                // color: Colors.amber,
                                borderRadius: BorderRadius.circular(15),
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  isFaqExpanded
                                      ? 'Show less FAQs'
                                      : 'Show more FAQs',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
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
                    child: Text('No data available'),
                  );
                }
              },
            ),
            (reviwed)
                ? FutureBuilder<Map<String, dynamic>>(
                    future: getReviews(widget
                        .courseName), // Use the new function to get reviews
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        // Extract review details if present
                        List<Map<String, dynamic>> userReview = [];
                        if (snapshot.data != null) {
                          userReview = snapshot.data!.entries.map((entry) {
                            return {
                              'email': entry.key, // Key is the user's email
                              'review': entry
                                  .value['review'], // Value is the review text
                              'rating': entry.value['rating'], // Include rating
                            };
                          }).toList();
                        }

                        // Return the review widget with the userReview list
                        return _review(
                            userReview); // Pass userReview to the _review method
                      } else {
                        return const Center(
                          child: Text('No reviews available'),
                        );
                      }
                    },
                  )
                : _writeReviewSection()
          ],
        ),
      ),
    );
  }
}
