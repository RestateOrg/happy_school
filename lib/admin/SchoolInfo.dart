import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolInfo extends StatefulWidget {
  final String name;

  const SchoolInfo({Key? key, required this.name}) : super(key: key);

  @override
  State<SchoolInfo> createState() => _SchoolInfoState();
}

class _SchoolInfoState extends State<SchoolInfo> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');
  final DocumentReference courseNamesRef = FirebaseFirestore.instance
      .collection("Content")
      .doc("Content")
      .collection("courseNames")
      .doc("courseNames");

  String searchQuery = ''; // Search query string
  List<bool> _isChecked = []; // List to store the checkbox state for cards
  List<String> courseNames = [];
  List<String> selectedcourses = [];
  List<String> userEmails = []; // List to store course names

  @override
  void initState() {
    super.initState(); // Fetch course names when the widget is initialized
  }

  // Fetch users for the school with optional filtering based on the search query
  Stream<List<String>> fetchUsersForSchool() {
    return usersRef.snapshots().asyncMap((snapshot) async {
      List<String> userEmails = [];

      for (var userDoc in snapshot.docs) {
        DocumentSnapshot userInfoDoc = await usersRef
            .doc(userDoc.id)
            .collection('userinfo')
            .doc('userinfo') // Ensure this is the correct doc ID
            .get();

        if (userInfoDoc.exists && userInfoDoc['school'] == widget.name) {
          final email = userInfoDoc['email'];
          // Apply search filter if the search query is not empty
          if (searchQuery.isEmpty || email.contains(searchQuery)) {
            userEmails.add(email);
          }
        } else {
          print('User info document does not exist or school does not match.');
        }
      }

      // Initialize the _isChecked list based on the number of users
      _isChecked = List<bool>.filled(userEmails.length, false);

      return userEmails;
    });
  }

  // Fetch course names from Firestore
  // Convert fetchCourseNames to return a Stream<List<String>>
  Stream<List<String>> fetchCourseNames() async* {
    try {
      DocumentSnapshot courseNamesDoc = await courseNamesRef.get();

      if (courseNamesDoc.exists) {
        final data = courseNamesDoc.data() as Map<String, dynamic>;

        // Check if the data is valid and contains the expected structure
        if (data.isNotEmpty) {
          courseNames = List<String>.from(data.values);
          _isChecked = List<bool>.filled(
              courseNames.length, false); // Initialize _isChecked
          yield courseNames; // Return the course names as a stream
        } else {
          print('No course names found.');
          yield [];
        }
      } else {
        print('Course names document does not exist.');
        yield [];
      }
    } catch (e) {
      print('Error fetching course names: $e');
      yield [];
    }
  }

  Future<void> _savechanges() async {
    if (selectedcourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one course to save.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await usersRef.get();

      for (var userDoc in snapshot.docs) {
        DocumentSnapshot userInfoDoc = await usersRef
            .doc(userDoc.id)
            .collection('userinfo')
            .doc('userinfo')
            .get();

        if (userInfoDoc.exists && userInfoDoc['school'] == widget.name) {
          // Use set instead of update to avoid errors if 'userinfo' doesn't exist
          await usersRef
              .doc(userDoc.id)
              .collection('userinfo')
              .doc('userinfo')
              .set({'courses': selectedcourses}, SetOptions(merge: true));
        } else {
          print('User info document does not exist or school does not match.');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving changes. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("School Details"),
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          _savechanges();
        },
        child: Container(
          height: 70,
          color: Colors.orange,
          child: const Center(
              child: Text(
            "Save",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          )),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search users by email',
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery =
                        query; // Update the search query on input change
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: StreamBuilder<List<String>>(
                  stream: fetchUsersForSchool(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Users (Loading...)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Text(
                        'Users (Error)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      );
                    }
                    // Display the number of users from the snapshot data
                    final userCount = snapshot.data?.length ?? 0;
                    return Text(
                      'Users ($userCount)',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),

            // First Container: Users list
            SizedBox(
              height: 200, // Fixed height for the ListView
              child: StreamBuilder<List<String>>(
                stream: fetchUsersForSchool(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Error in StreamBuilder: ${snapshot.error}');
                    return const Center(child: Text('Error fetching users.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No users found for this school.'));
                  }

                  userEmails = snapshot.data!;

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userEmails.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.orange,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8,
                                      ),
                                      child: Text(userEmails[index],
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Courses",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Second Container: Courses list with checkboxes
            SizedBox(
              height: 200, // Fixed height for the ListView
              child: StreamBuilder<List<String>>(
                stream: fetchCourseNames(), // Call the stream fetching method
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error fetching course names.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No courses available.'));
                  }

                  courseNames = snapshot.data!;
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courseNames.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              checkColor: Colors.white,
                              activeColor: Colors.orange,
                              value: _isChecked[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  _isChecked[index] = value!;
                                  if (value) {
                                    selectedcourses.add(courseNames[index]);
                                  } else {
                                    selectedcourses.remove(courseNames[index]);
                                  }
                                });
                              },
                            ),
                            title: Text(
                                courseNames[index]), // Display course names
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
