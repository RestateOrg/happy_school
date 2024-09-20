import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolInfo extends StatefulWidget {
  final String name;

  const SchoolInfo({Key? key, required this.name}) : super(key: key);

  @override
  State<SchoolInfo> createState() => _SchoolInfoState();
}

class _SchoolInfoState extends State<SchoolInfo> {
  // Reference to the Firestore "Users" collection
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');

  // Function to fetch users under the specific school
  Future<List<String>> fetchUsersForSchool() async {
    List<String> userEmails = [];

    try {
      QuerySnapshot snapshot = await usersRef.get();
      print('Documents fetched: ${snapshot.docs.length}'); // Debug output
    } catch (e) {
      print('Error fetching users: $e'); // Print the error
    }
    return userEmails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchUsersForSchool(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching users.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found for this school.'));
          }

          // List of user emails
          List<String> userEmails = snapshot.data!;

          return ListView.builder(
            itemCount: userEmails.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(userEmails[index]), // Display the user's email
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Action when edit icon is tapped
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
