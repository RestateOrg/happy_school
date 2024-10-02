import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Userleaderboard extends StatefulWidget {
  const Userleaderboard({super.key});

  @override
  State<Userleaderboard> createState() => _UserleaderboardState();
}

class _UserleaderboardState extends State<Userleaderboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getUsersInfo() async {
    try {
      // Reference to the 'users' collection
      final CollectionReference usersCollection =
          _firestore.collection('Users');

      // Fetch all documents from the 'users' collection
      QuerySnapshot usersSnapshot = await usersCollection.get();

      // Create a list to store user data
      List<Map<String, dynamic>> usersList = [];

      // Loop through the user documents
      for (var doc in usersSnapshot.docs) {
        // Reference to the 'userinfo' subcollection for each user
        DocumentReference userInfoDocRef =
            usersCollection.doc(doc.id).collection('userinfo').doc('userinfo');

        // Fetch userinfo document
        DocumentSnapshot userInfoSnapshot = await userInfoDocRef.get();
        print(userInfoSnapshot.data());

        if (userInfoSnapshot.exists && userInfoSnapshot.data() != null) {
          Map<String, dynamic> userInfoData =
              userInfoSnapshot.data() as Map<String, dynamic>;

          // Extract user details
          String name = userInfoData['Name'] ?? 'No name available';
          List<dynamic> courses = userInfoData['courses'] ?? [];
          String email = userInfoData['email']; // Email is the document ID
          String gender = userInfoData['gender'] ?? 'No gender specified';
          String phone = userInfoData['phone'] ?? 'No phone number available';
          String role = userInfoData['role'] ?? 'No role specified';
          String school = userInfoData['school'] ?? 'No school specified';
          int coins = userInfoData['coins'] ?? 0;

          // Add user details to the list
          usersList.add({
            'name': name,
            'courses': courses,
            'email': email,
            'gender': gender,
            'phone': phone,
            'role': role,
            'school': school,
            'coins': coins,
          });
        }
      }

      // Sort the list by coins in descending order
      usersList
          .sort((a, b) => (b['coins'] as int).compareTo(a['coins'] as int));

      return usersList;
    } catch (e) {
      print('Error fetching user data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getUsersInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              final usersList = snapshot.data!;

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: usersList.length,
                    itemBuilder: (context, index) {
                      //print(usersList.length);
                      final user = usersList[index];
                      return Container(
                        width: width * 0.93,
                        height: 100, // Increased height
                        padding: const EdgeInsets.all(8.0),
                        margin:
                            const EdgeInsets.only(bottom: 10), // Added margin
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(9, 0, 0, 0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromARGB(9, 0, 0, 0),
                            width: 0.25,
                          ),
                        ),
                        child: Row(
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
                            // Spacer(),
                            Padding(
                              padding: EdgeInsets.only(left: 10, top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        "assets/Images/coin.png",
                                      ),
                                      Text(
                                        user['coins'].toString(),
                                        style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                'Rank ' + (index + 1).toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            } else {
              return const Center(child: Text('No data found.'));
            }
          },
        ),
      ),
    );
  }
}
